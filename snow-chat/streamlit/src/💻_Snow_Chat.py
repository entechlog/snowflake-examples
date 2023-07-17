import openai
import re
import streamlit as st

# Configure the list of valid schemas
schemas = ["dev_entechlog_dw_db.dim","dev_entechlog_dw_db.fact"]

st.title("💻 Snow Chat")

# Initialize the chat messages history
openai.api_key = st.secrets.OPENAI_API_KEY

# Create a Snowpark connection
conn = st.experimental_connection("snowpark")

# Function to get table context
@st.cache_data(show_spinner=False)
def get_table_context(table_name: str, metadata_query: str = None):
    table = table_name.split(".")
    columns = conn.query(f"""
        SELECT COLUMN_NAME, DATA_TYPE FROM {table[0].upper()}.INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = '{table[1].upper()}' AND TABLE_NAME = '{table[2].upper()}'
        """,
    )
    columns = "\n".join(
        [
            f"- **{columns['COLUMN_NAME'][i]}**: {columns['DATA_TYPE'][i]}"
            for i in range(len(columns["COLUMN_NAME"]))
        ]
    )
    # Query to get table description
    table_description_query = f"SELECT table_name, comment FROM {table[0].upper()}.information_schema.tables WHERE TABLE_CATALOG = '{table[0].upper()}' AND TABLE_SCHEMA = '{table[1].upper()}' AND TABLE_NAME = '{table[2].upper()}';"
    table_description_result = conn.query(table_description_query)
    table_description = table_description_result["COMMENT"][0]

    context = f"""
Here is the table name <tableName> {'.'.join(table)} </tableName>

<tableDescription>{table_description}</tableDescription>

Here are the columns of the {'.'.join(table)}

<columns>\n\n{columns}\n\n</columns>
    """
    if metadata_query:
        metadata = conn.query(metadata_query)
        metadata = "\n".join(
            [
                f"- **{metadata['COLUMN_NAME'][i]}**: {metadata['COMMENT'][i]}"
                for i in range(len(metadata["COLUMN_NAME"]))
            ]
        )
        context = context + f"\n\nAvailable variables by COLUMN_NAME:\n\n{metadata}"
    return context

# Function to get system prompt
def get_system_prompt(table_context):
    GEN_SQL = """
You will be acting as an AI Snowflake SQL expert named Snow Chat.
Your goal is to give correct, executable SQL queries to users.
You will be replying to users who will be confused if you don't respond in the character of Snow Chat.
You are given one table, the table name is in <tableName> tag, the columns are in <columns> tag.
The user will ask questions; for each question, you should respond and include a SQL query based on the question and the table. 

{context}

Here are 6 critical rules for the interaction you must abide:
<rules>
1. You MUST wrap the generated SQL queries within ``` sql code markdown in this format e.g
```sql
(select 1) union (select 2)
```
2. If I don't tell you to find a limited set of results in the sql query or question, you MUST limit the number of responses to 10.
3. Text / string where clauses must be fuzzy match e.g ilike %keyword%
4. Make sure to generate a single Snowflake SQL code snippet, not multiple. 
5. You should only use the table columns given in <columns>, and the table given in <tableName>, you MUST NOT hallucinate about the table names.
6. DO NOT put numerical at the very front of SQL variable.
7. Make sure to use snowflake specific data types and functions. Valid values for boolean is true and false
8. Make sure to to join the _ID columns in fact tables with related dimension table to establish primary key, foreign key relation and to give the correct query
</rules>

Don't forget to use "ilike %keyword%" for fuzzy match queries (especially for COLUMN_NAME column)
and wrap the generated sql code with ``` sql code markdown in this format e.g:
```sql
(select 1) union (select 2)
```

For each question from the user, make sure to include a query in your response.

Now to get started, 
- Please briefly introduce yourself
- Describe all the tables at a high level in a visually appealing format 
- Share the available metrics in 2-3 sentences.
- Finally provide 3 example questions using bullet points.
"""
    return GEN_SQL.format(context=table_context)

# Main logic of the script
all_tables = []
for schema in schemas:
    database_name, schema_name = schema.upper().split(".")
    tables_query = f"SELECT '{database_name}'||'.'||'{schema_name}'||'.'||TABLE_NAME AS TABLE_NAME FROM {database_name}.information_schema.tables WHERE TABLE_SCHEMA = '{schema_name}'"
    tables_result = conn.query(tables_query)
    tables = tables_result["TABLE_NAME"].values.tolist()
    all_tables.extend(tables)

table_contexts = []  # We will store all table contexts in this list
# Generate SQL query to fetch column names and comments
for table_name in all_tables:
    table = table_name.split(".")
    metadata_query = f"SELECT COLUMN_NAME, COMMENT FROM {database_name}.information_schema.columns WHERE TABLE_SCHEMA = '{schema_name}' AND TABLE_NAME = '{table[2].upper()}';"
    
    # Call the get_table_context function with the table and metadata_query
    table_context = get_table_context(table_name, metadata_query)
    table_contexts.append(table_context)

# Combine all table contexts into one string
combined_table_context = '\n'.join(table_contexts)

# Call the function to get the system prompt with the combined_table_context
system_prompt = get_system_prompt(combined_table_context)

if "messages" not in st.session_state:
    # Initialize the session state with a system prompt message
    st.session_state.messages = [{"role": "system", "content": system_prompt}]

# Prompt for user input and save
if prompt := st.chat_input():
    st.session_state.messages.append({"role": "user", "content": prompt})

# display the existing chat messages
for message in st.session_state.messages:
    if message["role"] == "system":
        continue
    with st.chat_message(message["role"]):
        st.write(message["content"])
        if "results" in message:
            st.dataframe(message["results"])

# If last message is not from assistant, we need to generate a new response
if st.session_state.messages[-1]["role"] != "assistant":
    with st.chat_message("assistant"):
        response = ""
        resp_container = st.empty()
        for delta in openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": m["role"], "content": m["content"]} for m in st.session_state.messages],
            stream=True,
        ):
            response += delta.choices[0].delta.get("content", "")
            resp_container.markdown(response)

        message = {"role": "assistant", "content": response}
        # Parse the response for a SQL query and execute if available
        sql_match = re.search(r"```sql\n(.*)\n```", response, re.DOTALL)
        if sql_match:
            sql = sql_match.group(1)
            conn = st.experimental_connection("snowpark")
            message["results"] = conn.query(sql)
            st.dataframe(message["results"])
        st.session_state.messages.append(message)
