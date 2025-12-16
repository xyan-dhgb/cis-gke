import json
import html
from datetime import datetime
import os

def read_json_log(log_file='log.txt'):
    """Read JSON data from log file"""
    try:
        with open(log_file, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: {log_file} not found")
        return None
    except json.JSONDecodeError:
        print("Error: Invalid JSON format")
        return None

def read_previous_log(log_file='log_previous.txt'):
    """Read previous JSON log if it exists"""
    try:
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return None
    return None

def get_status_color(status):
    """Return color based on status"""
    status_lower = str(status).lower()
    if 'pass' in status_lower or 'success' in status_lower:
        return '#28a745'  # green
    elif 'fail' in status_lower or 'error' in status_lower:
        return '#dc3545'  # red
    elif 'warn' in status_lower or 'warning' in status_lower:
        return '#ffc107'  # yellow
    else:
        return '#6c757d'  # gray

def generate_html_report(data, output_file='report.html', previous_data=None):
    """Generate HTML report from JSON data with optional previous logs"""
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CIS Security Report</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }}
        .header {{
            background-color: #333;
            color: white;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 20px;
        }}
        .container {{
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }}
        .tabs {{
            display: flex;
            border-bottom: 2px solid #ddd;
            margin-bottom: 20px;
        }}
        .tab-button {{
            padding: 10px 20px;
            background-color: #f0f0f0;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }}
        .tab-button.active {{
            background-color: white;
            border-bottom-color: #333;
        }}
        .tab-button:hover {{
            background-color: #e0e0e0;
        }}
        .tab-content {{
            display: none;
        }}
        .tab-content.active {{
            display: block;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }}
        th {{
            background-color: #333;
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: bold;
        }}
        td {{
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }}
        tr:hover {{
            background-color: #f9f9f9;
        }}
        .status {{
            padding: 6px 12px;
            border-radius: 4px;
            color: white;
            font-weight: bold;
            text-align: center;
        }}
        .section-title {{
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-top: 20px;
            margin-bottom: 10px;
            padding-bottom: 10px;
            border-bottom: 2px solid #ddd;
        }}
    </style>
    <script>
        function openTab(evt, tabName) {{
            var i, tabcontent, tabbuttons;
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {{
                tabcontent[i].classList.remove("active");
            }}
            tabbuttons = document.getElementsByClassName("tab-button");
            for (i = 0; i < tabbuttons.length; i++) {{
                tabbuttons[i].classList.remove("active");
            }}
            document.getElementById(tabName).classList.add("active");
            evt.currentTarget.classList.add("active");
        }}
    </script>
</head>
<body>
    <div class="header">
        <h1>CIS Security Checks Report</h1>
        <p>Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    </div>
    <div class="container">
"""
    
    # Add tabs if previous data exists
    if previous_data:
        html_content += """        <div class="tabs">
            <button class="tab-button active" onclick="openTab(event, 'current')">Current Logs</button>
            <button class="tab-button" onclick="openTab(event, 'previous')">Previous Logs</button>
        </div>
"""
    
    # Current logs tab
    html_content += """        <div id="current" class="tab-content active">
            <div class="section-title">Current Security Check Results</div>
            <table>
                <thead>
                    <tr>
                        <th>DateTime</th>
                        <th>Check Name</th>
                        <th>Status</th>
                        <th>Log Details</th>
                    </tr>
                </thead>
                <tbody>
"""
    
    if isinstance(data, list):
        for item in data:
            status = item.get('status', 'Unknown')
            color = get_status_color(status)
            datetime_str = html.escape(str(item.get('datetime', 'N/A')))
            name = html.escape(str(item.get('name', 'N/A')))
            log = html.escape(str(item.get('log', '')))
            
            html_content += f"""                    <tr>
                        <td>{datetime_str}</td>
                        <td>{name}</td>
                        <td><span class="status" style="background-color: {color};">{status}</span></td>
                        <td>{log}</td>
                    </tr>
"""
    
    html_content += """                </tbody>
            </table>
        </div>
"""
    
    # Previous logs tab (if available)
    if previous_data:
        html_content += """        <div id="previous" class="tab-content">
            <div class="section-title">Previous Security Check Results</div>
            <table>
                <thead>
                    <tr>
                        <th>DateTime</th>
                        <th>Check Name</th>
                        <th>Status</th>
                        <th>Log Details</th>
                    </tr>
                </thead>
                <tbody>
"""
        
        if isinstance(previous_data, list):
            for item in previous_data:
                status = item.get('status', 'Unknown')
                color = get_status_color(status)
                datetime_str = html.escape(str(item.get('datetime', 'N/A')))
                name = html.escape(str(item.get('name', 'N/A')))
                log = html.escape(str(item.get('log', '')))
                
                html_content += f"""                    <tr>
                        <td>{datetime_str}</td>
                        <td>{name}</td>
                        <td><span class="status" style="background-color: {color};">{status}</span></td>
                        <td>{log}</td>
                    </tr>
"""
        
        html_content += """                </tbody>
            </table>
        </div>
"""
    
    html_content += """    </div>
</body>
</html>"""
    
    with open(output_file, 'w') as f:
        f.write(html_content)
    print(f"Report generated: {output_file}")

if __name__ == '__main__':
    data = read_json_log('log.txt')
    previous_data = read_previous_log('log_previous.txt')
    if data:
        generate_html_report(data, 'report.html', previous_data)