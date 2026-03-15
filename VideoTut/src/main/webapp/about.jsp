<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="ISO-8859-1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - YouTube Video Suggestion System</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,300&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        :root {
            --red: #FF0000;
            --red-dark: #CC0000;
            --red-glow: rgba(255,0,0,0.25);
            --bg: #0A0A0A;
            --surface: #141414;
            --surface2: #1C1C1C;
            --text: #F5F5F5;
            --text-muted: #8A8A8A;
            --border: rgba(255,255,255,0.08);
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
        }

        /* Top accent bar */
        .topbar {
            height: 3px;
            background: linear-gradient(90deg, var(--red), #ff6666, transparent);
        }

        header {
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            padding: 18px 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .brand-icon {
            width: 34px; height: 24px;
            background: var(--red);
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 10px var(--red-glow);
        }

        .brand-icon::after {
            content: '';
            border-left: 10px solid white;
            border-top: 6px solid transparent;
            border-bottom: 6px solid transparent;
            margin-left: 2px;
        }

        .brand-name {
            font-family: 'Syne', sans-serif;
            font-weight: 800;
            font-size: 17px;
        }

        .header-actions {
            display: flex;
            gap: 10px;
        }

        .header-actions a {
            text-decoration: none;
            padding: 8px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s;
        }

        .btn-outline {
            color: var(--text-muted);
            border: 1px solid var(--border);
        }

        .btn-outline:hover { background: var(--surface2); color: var(--text); }

        .btn-primary {
            background: var(--red);
            color: white;
            box-shadow: 0 3px 12px var(--red-glow);
        }

        .btn-primary:hover { background: var(--red-dark); }

        /* Hero */
        .hero {
            text-align: center;
            padding: 70px 20px 50px;
            position: relative;
        }

        .hero::before {
            content: '';
            position: absolute;
            top: 0; left: 50%;
            transform: translateX(-50%);
            width: 500px; height: 300px;
            background: radial-gradient(circle, rgba(255,0,0,0.1) 0%, transparent 70%);
            pointer-events: none;
        }

        .badge {
            display: inline-block;
            background: rgba(255,0,0,0.12);
            border: 1px solid rgba(255,0,0,0.25);
            color: #ff8888;
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 0.5px;
            margin-bottom: 20px;
        }

        .hero h1 {
            font-family: 'Syne', sans-serif;
            font-size: clamp(30px, 5vw, 50px);
            font-weight: 800;
            letter-spacing: -1px;
            margin-bottom: 16px;
        }

        .hero h1 span { color: var(--red); }

        .hero p {
            font-size: 16px;
            color: var(--text-muted);
            max-width: 560px;
            margin: 0 auto;
            line-height: 1.7;
        }

        /* Content */
        .content {
            max-width: 860px;
            margin: 0 auto;
            padding: 0 24px 80px;
        }

        /* Section */
        .section {
            margin-bottom: 36px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 32px;
            animation: fadeIn 0.5s ease both;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 18px;
        }

        .section-icon {
            width: 36px; height: 36px;
            background: rgba(255,0,0,0.12);
            border-radius: 9px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0;
        }

        .section h2 {
            font-family: 'Syne', sans-serif;
            font-size: 18px;
            font-weight: 700;
        }

        .section p {
            color: var(--text-muted);
            font-size: 15px;
            line-height: 1.75;
        }

        /* Feature list */
        .feature-list {
            list-style: none;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-top: 4px;
        }

        .feature-list li {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.5;
        }

        .feature-list li::before {
            content: '&#10003;';
            color: var(--red);
            font-weight: 700;
            flex-shrink: 0;
            margin-top: 1px;
        }

        /* Tech grid */
        .tech-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 12px;
        }

        .tech-item {
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 14px 16px;
        }

        .tech-label {
            font-size: 11px;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.8px;
            margin-bottom: 4px;
        }

        .tech-value {
            font-size: 14px;
            font-weight: 500;
            color: var(--text);
        }

        /* Workflow */
        .workflow-steps {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .step {
            display: flex;
            align-items: flex-start;
            gap: 16px;
        }

        .step-num {
            width: 32px; height: 32px;
            background: var(--red);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Syne', sans-serif;
            font-weight: 700;
            font-size: 13px;
            flex-shrink: 0;
            box-shadow: 0 2px 10px var(--red-glow);
        }

        .step-text {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.5;
            padding-top: 6px;
        }

        .step-text strong { color: var(--text); }

        /* Flowchart */
        .flowchart {
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 12px;
            overflow: hidden;
            margin-top: 8px;
        }

        .flowchart img {
            width: 100%;
            display: block;
        }

        @keyframes fadeIn {
            from { opacity:0; transform: translateY(12px); }
            to   { opacity:1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<div class="topbar"></div>

<header>
    <div class="brand">
        <div class="brand-icon"></div>
        <span class="brand-name">VideoTut</span>
    </div>
    <div class="header-actions">
        <a href="homepage/index.jsp" class="header-actions btn-outline">&#8592; Home</a>
        <a href="login.jsp" class="header-actions btn-outline">User Login</a>
        <a href="admin/adminLogin.jsp" class="header-actions btn-primary">Admin Panel</a>
    </div>
</header>

<div class="hero">
    <div class="badge">B.Tech CSE Project</div>
    <h1>YouTube <span>Video</span> Suggestion System</h1>
    <p>A full-stack web project built with JSP, Oracle Database, and the YouTube Data API v3.</p>
</div>

<div class="content">

    <div class="section">
        <div class="section-header">
            <div class="section-icon">&#127919;</div>
            <h2>Project Objective</h2>
        </div>
        <p>
            The objective of this project is to develop a YouTube Video Suggestion System using JSP.
            The system allows users to search for educational or entertainment videos directly from YouTube
            with the help of the YouTube Data API. All user search activity is stored in an Oracle database.
            The project also includes separate dashboards for users and admin to manage searches and view analytics.
        </p>
    </div>

    <div class="section">
        <div class="section-header">
            <div class="section-icon">&#10024;</div>
            <h2>Key Features</h2>
        </div>
        <ul class="feature-list">
            <li>User registration and login functionality</li>
            <li>Search and fetch YouTube videos using YouTube Data API v3</li>
            <li>Display video details such as title and link</li>
            <li>Store user search history in Oracle database</li>
            <li>Admin dashboard to view search statistics</li>
            <li>Graphical reports generated using Google Charts</li>
        </ul>
    </div>

    <div class="section">
        <div class="section-header">
            <div class="section-icon">&#9881;</div>
            <h2>Technologies Used</h2>
        </div>
        <div class="tech-grid">
            <div class="tech-item">
                <div class="tech-label">Frontend</div>
                <div class="tech-value">JSP, HTML5, CSS3</div>
            </div>
            <div class="tech-item">
                <div class="tech-label">Backend</div>
                <div class="tech-value">Java (JSP & Servlets)</div>
            </div>
            <div class="tech-item">
                <div class="tech-label">Database</div>
                <div class="tech-value">Oracle 11g / 19c</div>
            </div>
            <div class="tech-item">
                <div class="tech-label">API</div>
                <div class="tech-value">YouTube Data API v3</div>
            </div>
            <div class="tech-item">
                <div class="tech-label">Charts</div>
                <div class="tech-value">Google Charts</div>
            </div>
        </div>
    </div>

    <div class="section">
        <div class="section-header">
            <div class="section-icon">&#9654;</div>
            <h2>Project Workflow</h2>
        </div>
        <div class="workflow-steps">
            <div class="step">
                <div class="step-num">1</div>
                <div class="step-text"><strong>Register &amp; Login:</strong> User registers and logs into the system with email and password.</div>
            </div>
            <div class="step">
                <div class="step-num">2</div>
                <div class="step-text"><strong>Search:</strong> User enters a search keyword, for example &ldquo;Java Tutorial&rdquo;.</div>
            </div>
            <div class="step">
                <div class="step-num">3</div>
                <div class="step-text"><strong>API Call:</strong> JSP sends a request to YouTube using the YouTube Data API.</div>
            </div>
            <div class="step">
                <div class="step-num">4</div>
                <div class="step-text"><strong>Display:</strong> The server processes the response and displays video results with embedded players.</div>
            </div>
            <div class="step">
                <div class="step-num">5</div>
                <div class="step-text"><strong>Database:</strong> User search details are stored in the Oracle database for history tracking.</div>
            </div>
            <div class="step">
                <div class="step-num">6</div>
                <div class="step-text"><strong>Admin Analytics:</strong> Admin can view top searched topics, user activity charts, and detailed logs.</div>
            </div>
        </div>
    </div>

    <div class="section">
        <div class="section-header">
            <div class="section-icon">&#128202;</div>
            <h2>System Flow Diagram</h2>
        </div>
        <div class="flowchart">
            <img src="flow_diagram.png" alt="System Flow Diagram">
        </div>
    </div>

</div>

</body>
</html>
