import streamlit as st

st.title("❄️ Validate connection - Snowflake")

conn = st.experimental_connection("snowpark")
df = conn.query("select current_warehouse()")
st.write(df)
