module "lambda_function" {
  # module to create lambda resources in aws
  source               = "./modules/lambda"
  lambda_function_name = ["textract_detect_text", "textract_analyze_doc"]
}