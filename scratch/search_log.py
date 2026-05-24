import json

log_path = r"C:\Users\dayon\.gemini\antigravity-ide\brain\e0c75376-12d3-4bdb-88b8-324963020022\.system_generated\logs\transcript.jsonl"

with open(log_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

print("TOTAL LINES:", len(lines))
for i, line in enumerate(lines):
    try:
        data = json.loads(line)
        step_type = data.get('type', '')
        content = data.get('content', '')
        if step_type == "USER_INPUT":
            print(f"\n[Step {data.get('step_index')}] USER:")
            # Extract request inside <USER_REQUEST>
            import re
            m = re.search(r'<USER_REQUEST>(.*?)</USER_REQUEST>', content, re.DOTALL)
            if m:
                print(m.group(1).strip())
            else:
                print(content[:200])
        
        # If the model uses generate_image or shares an image, print it
        if data.get('source') == "MODEL":
            tool_calls = data.get('tool_calls', [])
            for tc in tool_calls:
                if tc.get('name') == 'generate_image':
                    print(f"  [Step {data.get('step_index')}] generate_image:", tc.get('args'))
                elif tc.get('name') == 'write_to_file' and 'walkthrough' in str(tc.get('args')):
                    print(f"  [Step {data.get('step_index')}] write walkthrough.md")
    except Exception as e:
        pass
