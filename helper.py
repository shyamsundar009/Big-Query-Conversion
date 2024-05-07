import json

def extract_json(input_string):
    # Find JSON data in the input string
    json_strings = []
    start = 0
    while True:
        start = input_string.find("{", start)
        if start == -1:
            break
        end = input_string.find("}", start) + 1
        json_data = input_string[start:end]
        json_strings.append(json_data)
        start = end

    # Parse and print JSON data
    for json_data in json_strings:
        try:
            parsed_json = json.loads(json_data)
            print("JSON data:", parsed_json)
        except json.JSONDecodeError as e:
            print("Error parsing JSON:", e)
            parsed_json = input_string
    
    return parsed_json

def read_sql(sql_path):
    with open(sql_path, 'r') as f:
        data = f.read()
    
    return data

def save_text_file(output_file_path, text):
    with open(output_file_path, 'w') as file:
        file.write(text)

def save_json(output_file_path, data):
    with open(output_file_path, 'w') as f:
        json.dump(data, f)