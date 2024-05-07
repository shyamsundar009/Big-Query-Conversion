import os
from bs4 import BeautifulSoup
from typing import AnyStr, Tuple

from helper import *
from config import *
from hit_genai_apis import *
from feeback_prompts import *
from query_conversion_prompts import *

class Judge:
    def __init__(self) -> None:
        self.file_directory = os.path.dirname(os.path.abspath(__file__))
        self.hit_api_obj = HitAPI()
        
    def correctness_prompt(self, oracle_code, ms_sql_code) -> AnyStr:
        body_prompt = body_correctness.format(oracle_sql_code = oracle_code, ms_sql_code = ms_sql_code, output_format = output_format_scores)
        return body_prompt
    
    def post_process_output(self, output):
        soup = BeautifulSoup(output, 'html.parser')

        rating_tag = soup.find('rating')
        feedback_tag = soup.find('feedback')

        if rating_tag:
            rating = int(rating_tag.text)
        else:
            rating = -1

        if feedback_tag:
            feedback = feedback_tag.text
        else:
            feedback = None

        return rating, feedback

    def judgement(self, 
                  oracle_code: AnyStr, 
                  ms_sql_code: AnyStr, 
                  file_base_name: AnyStr, 
                  output_directory = judgement_output_directory,
                  save_judgement_json = True) -> Tuple:
        
        if file_base_name.find('.sql') != -1:
            file_base_name = '.'.join(file_base_name.split('.')[:-1])

        body_prompt = self.correctness_prompt(oracle_code, ms_sql_code)
        gpt_output = self.post_process_output(self.hit_api_obj.hit_gpt(prompt = body_prompt, prompt_header = header_correctness))
        claude_output = self.post_process_output(self.hit_api_obj.hit_claude(prompt = body_prompt, prompt_header = header_correctness))
        gemini_output = self.post_process_output(self.hit_api_obj.hit_gemini(prompt = body_prompt, prompt_header = header_correctness))
        avg_rating = round((int(gpt_output[0]) + int(claude_output[0]) + int(gemini_output[0]))/3, 1)

        judgement = {
            "gpt": gpt_output,
            "claude": claude_output,
            "gemini": gemini_output
            }
        
        if save_judgement_json:
            output_file_path = os.path.join(self.file_directory, output_directory, file_base_name + '.json').lstrip(os.sep)
            save_json(output_file_path=output_file_path, data = judgement)
            return judgement, avg_rating, output_file_path
            
        return judgement, avg_rating