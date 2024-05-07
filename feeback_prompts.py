header_correctness = """You are the most advanced coding AI Judge and Instructor, designed to check the correctness of translated MS SQL code from Oracle SQL code."""
body_correctness = """Below is an Oracle SQL code which has been translated to MS SQL code. 
Oracle SQL code:
'''{oracle_sql_code}'''

The translated MS SQL code is given below:
'''{ms_sql_code}'''

Please judge the correctness of the MS SQL code provided above, which has been translated from Oracle SQL code. Rate the translated MS SQL code based on the below criterias:
1. Syntax Accuracy: Assess whether the MS SQL code adheres to the correct syntax and grammar rules of MS SQL SQL, ensuring that keywords, clauses, and punctuation are used appropriately.
2. Semantic Equivalence: Verify that the MS SQL code produces the same logical output as the original Oracle SQL code, ensuring that the intended data is retrieved, filtered, and manipulated correctly.
3. Functionality: Evaluate whether the MS SQL code achieves the desired objective specified in the original Oracle SQL code, such as retrieving, updating, or deleting data from the database.
4. Portability: Consider the compatibility of the MS SQL code with MS SQL-specific features, versions, and configurations, ensuring that it can be executed reliably across different MS SQL environments.
5. Scalability: Evaluate whether the MS SQL code is designed to accommodate future growth in data volume, user traffic, and complexity of operations, ensuring that it can scale efficiently without compromising performance or stability over time.
6. Completeness: Assess the completeness of the MS SQL code, ensuring that it covers all necessary aspects required for the desired functionality and does not overlook any critical components.

Give the output as a score ranging from 0 to 5, where,
0 - The MS SQL code contains significant errors that render it unusable or completely incorrect. It fails to achieve the desired functionality and may require extensive rework.
1 - The MS SQL code contains several errors that hinder its functionality and require substantial modifications to function properly. The translated code deviates significantly from the original Oracle SQL logic.
2 - Although the MS SQL code contains some errors, the overall logic is preserved, and it partially achieves the desired functionality. However, significant improvements are necessary to ensure accurate execution and alignment with the original Oracle SQL code.
3 - The MS SQL code contains minor errors that do not significantly impact its functionality. While the code functions adequately, there is room for improvement to enhance accuracy, efficiency, and adherence to MS SQL syntax and best practices.
4 - The MS SQL code is nearly perfect, with only minimal adjustments needed for optimization. It closely aligns with the original Oracle SQL code in terms of functionality, syntax, completeness and performance. However, there may be minor areas for refinement to achieve optimal efficiency and maintainability.
5 - The MS SQL code is a perfect translation of the Oracle SQL code, demonstrating identical functionality, structure, completeness and performance characteristics. It accurately reflects the logic and intent of the original code without any discrepancies or errors.

Also, act as a Coding Instructor to give the most accurate and detailed instructions based on the judgement criterias, on the next steps to perfectly translate the oracle code to get a rating of 5.
If your rating is already 5, the feedback should be "Perfect Translation.".

The output should be in the below dictionary format:
{output_format}

Finally, verify all of the above thoroughly and give the output in the format given above.

Your output:"""

output_format_scores = """<rating>YOUR_RATING</rating>,
<feedback>YOUR_FEEDBACK</feedback>"""