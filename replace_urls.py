import os

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content.replace('admin.gobuddyindia.com', 'dev.gobuddyindia.com')
        new_content = new_content.replace('assets/images/appLogo.png', 'assets/images/logoImg.png')

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {filepath}")
    except Exception as e:
        print(f"Error reading {filepath}: {e}")

def main():
    lib_dir = r"c:\Users\ADMIN\Desktop\GB-Customer-main\GB-Customer-main\lib"
    
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                replace_in_file(filepath)

if __name__ == "__main__":
    main()
