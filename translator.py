import os
import time
from datetime import timedelta

from helper import *
from config import *
from hit_genai_apis import *
from feeback_prompts import *
from query_conversion_prompts import *

class CodeTranslator:
    def __init__(self) -> None:
        self.file_directory = os.path.dirname(os.path.abspath(__file__))
        self.converted_code = ''

        self.hit_api_obj = HitAPI()

    def post_process_output(self, output):
        conversion_completed = False

        if output.find('<translated_code>') != -1 or output.find('<incomplete_translated_code>') != -1:
            if output.find('<translated_code>') != -1:
                output = output.split('<translated_code>')[1]
            elif output.find('<incomplete_translated_code>') != -1:
                output = output.split('<incomplete_translated_code>')[1]
            else:
                output = output

        if output.find('</translated_code>') != -1:
            conversion_completed = True
            output = output.split('</translated_code>')[0]
        return output, conversion_completed
    
    def save_translated_code(self, output_file_path) -> None:
        save_text_file(output_file_path, text = self.converted_code)

    def translate(self, oracle_sql_code, file_base_name, output_directory, save_converted_code = True):
        lines_of_code = len(oracle_sql_code.split('\n'))

        prompt = oracle_sql_conversion_prompt.format(oracle_sql_code = oracle_sql_code)

        begin = time.time()
        response = self.hit_api_obj.hit_claude(prompt=prompt, prompt_header=oracle_sql_conversion_header)
        total_elapsed_time = time.time() - begin

        output, conversion_completed = self.post_process_output(output = response)
        self.converted_code += output
        
        while not conversion_completed: # when output is partial
            prompt = prompt + '\n' + code_completion_prompt.format(code = self.converted_code)
            second_begin = time.time()
            response = self.hit_api_obj.hit_claude(prompt=prompt, prompt_header=oracle_sql_conversion_header)
            total_elapsed_time += time.time() - second_begin
            output, conversion_completed = self.post_process_output(output = response)
            self.converted_code += output

        print(f'It took {str(timedelta(seconds=round(total_elapsed_time)))} to convert {lines_of_code} lines of code, from {file_base_name} file.')

        if save_converted_code:
            output_file_path = os.path.join(self.file_directory, output_directory, 'MS_SQL_' + file_base_name).lstrip(os.sep)
            self.save_translated_code(output_file_path=output_file_path)
            return self.converted_code, output_file_path

        return self.converted_code
    
    
