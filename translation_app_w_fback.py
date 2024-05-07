import os
import base64
from shutil import rmtree
import streamlit as st

from config import *
from helper import *
from translator import CodeTranslator
from translation_judge import Judge

class TranslationApp:
    def __init__(self) -> None:
        self.file_directory = os.path.dirname(os.path.abspath(__file__))
        self.temp_output_storage_folder = os.path.join(self.file_directory, app_temp_output_storage_folder)
        self.background_image_path = os.path.join(self.file_directory, background_image_path)
        os.makedirs(self.temp_output_storage_folder, exist_ok=True)

        self.code_converter_obj = CodeTranslator()
        self.judgement_obj = Judge()

    def centered_title(self, title_text, heading = 'h1', alignment = 'center'):
        """Displays a centered title."""
        st.markdown(f"""<{heading} style="text-align: {alignment};">{title_text}</{heading}>""", unsafe_allow_html=True)

    def get_base64(self, bin_file):
        with open(bin_file, 'rb') as f:
            data = f.read()
        return base64.b64encode(data).decode()

    def set_background(self, png_file):
        bin_str = self.get_base64(png_file)
        page_bg_img = '''
        <style>
        .stApp {
        background-image: url("data:image/png;base64,%s");
        background-size: cover;
        }
        </style>
        ''' % bin_str
        st.markdown(page_bg_img, unsafe_allow_html=True)
    
    def save_translated_code(self, converted_code, output_file_path) -> None:
        save_text_file(output_file_path, text = converted_code)

    def get_binary_file_downloader_html(self, bin_file, file_label='File'):
        with open(bin_file, 'rb') as f:
            data = f.read()
        b64 = base64.b64encode(data).decode()
        href = f'<a href="data:application/octet-stream;base64,{b64}" download="{os.path.basename(bin_file)}">{file_label}</a>'
        return href
    
    def translate_code_and_give_download_link(self, oracle_sql_code, source_code_name):
        converted_code, output_path = self.code_converter_obj.translate(
                                                            oracle_sql_code = oracle_sql_code, 
                                                            file_base_name = source_code_name,      
                                                            output_directory = self.temp_output_storage_folder,
                                                            save_converted_code = True)
                    
        st.markdown(self.get_binary_file_downloader_html(output_path, f"Download converted SQL: {source_code_name}"), unsafe_allow_html=True)
        
        return converted_code
    
    def show_feedback(self, oracle_sql_code, converted_code, source_code_name) -> None:
        judgement, score = self.judgement_obj.judgement(
                                                oracle_code=oracle_sql_code, 
                                                ms_sql_code=converted_code, 
                                                file_base_name = source_code_name,
                                                output_directory = self.temp_output_storage_folder,
                                                save_judgement_json = False
                                            )
        
        self.centered_title(f"Average Score of the converted code: {score}", heading= 'h2', alignment= 'left')
        for k in judgement.keys():
            self.centered_title(k.capitalize(), heading= 'h3', alignment= 'left')
            st.write(f'Score: {judgement[k][0]}')
            st.write('Feedback: ' + judgement[k][1])
        
        return None


    def main(self):
        self.set_background(self.background_image_path)
        self.centered_title("Oracle SQL to MS SQL Conversion App")

        uploaded_files = st.file_uploader("Choose Oracle SQL files to convert.", accept_multiple_files=True)
        source_code_name = st.text_input("Enter the name of the SQL code:")
        oracle_sql_code = st.text_area("Enter source code to convert", height=400)


        if st.button("Convert"):
            if uploaded_files:

                for uploaded_file in uploaded_files:
                    source_code_name = uploaded_file.name
                    oracle_sql_code = uploaded_file.getvalue().decode("utf-8")                    
                    converted_code = self.translate_code_and_give_download_link(
                                                                                oracle_sql_code = oracle_sql_code, 
                                                                                source_code_name = source_code_name, 
                                                                                )
                    
                    # self.show_feedback(oracle_sql_code, converted_code, source_code_name)

            else:
                if oracle_sql_code.strip() == "":
                    st.error("Please enter SQL code")
                elif source_code_name.strip() == "":
                    st.error("Please enter the name of the SQL code")
                else:
                    converted_code = self.translate_code_and_give_download_link(
                                                                                oracle_sql_code = oracle_sql_code, 
                                                                                source_code_name = source_code_name, 
                                                                                )
                    # Display the converted code
                    st.code(converted_code, language="sql")
                    # self.show_feedback(oracle_sql_code, converted_code, source_code_name)
            
            rmtree(self.temp_output_storage_folder)
                
if __name__ == "__main__":
    app_obj = TranslationApp()
    app_obj.main()