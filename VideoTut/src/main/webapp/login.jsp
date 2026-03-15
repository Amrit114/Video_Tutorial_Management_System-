<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>User Login - YouTube Video Suggestion</title>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
    *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

    :root {
        --red: #FF0000;
        --red-dark: #CC0000;
        --red-glow: rgba(255,0,0,0.3);
        --bg: #0A0A0A;
        --surface: #141414;
        --surface2: #1C1C1C;
        --text: #F5F5F5;
        --text-muted: #888;
        --border: rgba(255,255,255,0.1);
        --border-focus: rgba(255,0,0,0.5);
    }

    body {
        font-family: 'DM Sans', sans-serif;
        background: var(--bg);
        color: var(--text);
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }

    body::after {
        content: '';
        position: fixed;
        top: -150px; left: 50%;
        transform: translateX(-50%);
        width: 600px; height: 600px;
        background: radial-gradient(circle, rgba(255,0,0,0.12) 0%, transparent 70%);
        pointer-events: none;
        z-index: 0;
    }

    .card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 18px;
        padding: 44px 40px;
        width: 100%;
        max-width: 400px;
        position: relative;
        z-index: 1;
        box-shadow: 0 24px 60px rgba(0,0,0,0.5);
        animation: slideUp 0.5s ease both;
    }

    .card-header {
        text-align: center;
        margin-bottom: 32px;
    }

    .logo-icon {
        width: 40px; height: 28px;
        background: var(--red);
        border-radius: 7px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 16px;
        box-shadow: 0 4px 16px var(--red-glow);
    }

    .logo-icon::after {
        content: '';
        border-left: 12px solid white;
        border-top: 7px solid transparent;
        border-bottom: 7px solid transparent;
        margin-left: 2px;
    }

    h2 {
        font-family: 'Syne', sans-serif;
        font-size: 26px;
        font-weight: 800;
        letter-spacing: -0.5px;
        color: white;
    }

    .card-header p {
        color: var(--text-muted);
        font-size: 14px;
        margin-top: 6px;
    }

    .field {
        margin-bottom: 16px;
    }

    label {
        display: block;
        font-size: 12px;
        font-weight: 500;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.8px;
        margin-bottom: 7px;
    }

    input[type=email],
    input[type=password],
    input[type=text] {
        width: 100%;
        padding: 13px 16px;
        background: var(--surface2);
        border: 1px solid var(--border);
        border-radius: 10px;
        color: var(--text);
        font-family: 'DM Sans', sans-serif;
        font-size: 15px;
        outline: none;
        transition: border-color 0.2s, box-shadow 0.2s;
    }

    input[type=email]:focus,
    input[type=password]:focus,
    input[type=text]:focus {
        border-color: var(--border-focus);
        box-shadow: 0 0 0 3px rgba(255,0,0,0.1);
    }

    input[type=email]::placeholder,
    input[type=password]::placeholder,
    input[type=text]::placeholder {
        color: #444;
    }

    input[type=submit] {
        width: 100%;
        padding: 14px;
        background: var(--red);
        color: white;
        border: none;
        border-radius: 10px;
        font-family: 'DM Sans', sans-serif;
        font-size: 15px;
        font-weight: 600;
        cursor: pointer;
        margin-top: 8px;
        transition: background 0.2s, transform 0.15s, box-shadow 0.2s;
        box-shadow: 0 4px 20px var(--red-glow);
    }

    input[type=submit]:hover {
        background: var(--red-dark);
        transform: translateY(-1px);
        box-shadow: 0 6px 28px rgba(255,0,0,0.45);
    }

    .msg-error {
        background: rgba(255,0,0,0.1);
        border: 1px solid rgba(255,0,0,0.3);
        color: #ff6666;
        padding: 11px 14px;
        border-radius: 9px;
        font-size: 14px;
        margin-bottom: 16px;
        text-align: center;
    }

    .card-footer {
        margin-top: 24px;
        text-align: center;
        font-size: 13px;
        color: var(--text-muted);
    }

    .card-footer a {
        color: var(--red);
        text-decoration: none;
        font-weight: 500;
    }

    .card-footer a:hover { text-decoration: underline; }

    .back-btn {
        display: inline-block;
        margin-top: 10px;
        color: var(--text-muted) !important;
        font-size: 13px;
    }

    @keyframes slideUp {
        from { opacity:0; transform: translateY(20px); }
        to   { opacity:1; transform: translateY(0); }
    }
</style>
</head>
<body>

<div class="card">
    <div class="card-header">
        <div class="logo-icon"></div>
        <h2>Welcome Back</h2>
        <p>Sign in to your account</p>
    </div>

    <%
    if(request.getMethod().equalsIgnoreCase("post")){
        String email = request.getParameter("email");
        String pass = request.getParameter("password");

        try{
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");

            PreparedStatement ps = con.prepareStatement("SELECT id, name FROM vdusers WHERE email=? AND password=?");
            ps.setString(1, email);
            ps.setString(2, pass);
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                session.setAttribute("uid", rs.getInt("id"));
                session.setAttribute("uname", rs.getString("name"));
                response.sendRedirect("dashboard.jsp");
            } else {
                out.println("<div class='msg-error'>&#10005; Invalid email or password. Please try again.</div>");
            }

            con.close();
        } catch(Exception e){
            out.println("<div class='msg-error'>&#10005; Error: "+e.getMessage()+"</div>");
        }
    }
    %>

    <form method="post">
        <div class="field">
            <label>Email Address</label>
            <input type="email" name="email" placeholder="you@example.com" required>
        </div>
        <div class="field">
            <label>Password</label>
            <input type="password" name="password" placeholder="Enter your password" required>
        </div>
        <input type="submit" value="Sign In">
    </form>

    <div class="card-footer">
        <p>Don't have an account? <a href="register.jsp">Register here</a></p>
        <a href="homepage/index.jsp" class="back-btn">&#8592; Back to Home</a>
    </div>
</div>

</body>
</html>
