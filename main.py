import os

from config import *
from helper import *
from translator import CodeTranslator
from translation_judge import Judge

source_code_file_path = r"C:\Users\sudipt\Documents\workspace\Big-Query-Conversion\data\input\NYU_PRENATAL.sql"
source_code = read_sql(source_code_file_path)
source_code_filename = os.path.basename(source_code_file_path).split('.')[0]

'''
If you want to generate a new translation, comment below code block and uncomment 'translated_code'
'''
#
translated_code_file_path = r"C:\Users\sudipt\Documents\workspace\Big-Query-Conversion\data\output\direct_conversion\claude\TEST_ORACLE_STORED_PROCEDURE.sql"
translated_code = read_sql(source_code_file_path)
#

code_translator_obj = CodeTranslator()
judge_obj = Judge()

translated_code = code_translator_obj.translate(
                                                oracle_sql_code = source_code, 
                                                file_base_name = source_code_filename,
                                                output_directory = claude_output_directory,
                                                save_converted_code=False
                                                )

judgement, score, output_json_path = judge_obj.judgement(
                                                oracle_code=source_code, 
                                                ms_sql_code=translated_code, 
                                                file_base_name = source_code_filename,
                                                save_judgement_json = True
                                            )

print('Avg. rating of the translated code is: ', score)
# print(translated_code)