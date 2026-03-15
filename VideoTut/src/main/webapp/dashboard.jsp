<%@ page import="java.sql.*, java.io.*, java.net.*, org.json.*, java.util.*" %>

<%
    Integer uid = (Integer)session.getAttribute("uid");
    String uname = (String)session.getAttribute("uname");
    if(uid == null){
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard - YouTube Suggestion</title>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
    *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

    :root {
        --red: #FF0000;
        --red-dark: #CC0000;
        --red-glow: rgba(255,0,0,0.25);
        --bg: #0A0A0A;
        --surface: #141414;
        --surface2: #1C1C1C;
        --surface3: #222;
        --text: #F5F5F5;
        --text-muted: #888;
        --border: rgba(255,255,255,0.08);
    }

    body {
        font-family: 'DM Sans', sans-serif;
        background: var(--bg);
        color: var(--text);
        min-height: 100vh;
    }

    /* Top Nav */
    .topnav {
        background: var(--surface);
        border-bottom: 1px solid var(--border);
        padding: 0 32px;
        height: 60px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        position: sticky;
        top: 0;
        z-index: 100;
    }

    .nav-brand {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .nav-icon {
        width: 32px; height: 22px;
        background: var(--red);
        border-radius: 5px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 10px var(--red-glow);
    }

    .nav-icon::after {
        content: '';
        border-left: 9px solid white;
        border-top: 5px solid transparent;
        border-bottom: 5px solid transparent;
        margin-left: 2px;
    }

    .nav-title {
        font-family: 'Syne', sans-serif;
        font-weight: 800;
        font-size: 16px;
    }

    .nav-right {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .user-badge {
        font-size: 13px;
        color: var(--text-muted);
    }

    .user-badge strong {
        color: var(--text);
        font-weight: 500;
    }

    .logout-btn {
        text-decoration: none;
        background: rgba(255,0,0,0.12);
        color: var(--red);
        border: 1px solid rgba(255,0,0,0.25);
        padding: 7px 16px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        transition: all 0.2s;
    }

    .logout-btn:hover {
        background: rgba(255,0,0,0.22);
    }

    /* Layout */
    .layout {
        display: grid;
        grid-template-columns: 300px 1fr;
        gap: 0;
        min-height: calc(100vh - 60px);
    }

    /* Sidebar */
    .sidebar {
        background: var(--surface);
        border-right: 1px solid var(--border);
        padding: 28px 20px;
        overflow-y: auto;
    }

    .sidebar-section {
        margin-bottom: 32px;
    }

    .sidebar-title {
        font-size: 11px;
        font-weight: 600;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 14px;
        padding: 0 8px;
    }

    /* Search form in sidebar */
    .search-form {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .search-form input[type=text] {
        width: 100%;
        padding: 11px 14px;
        background: var(--surface2);
        border: 1px solid var(--border);
        border-radius: 9px;
        color: var(--text);
        font-family: 'DM Sans', sans-serif;
        font-size: 14px;
        outline: none;
        transition: border-color 0.2s;
    }

    .search-form input[type=text]:focus {
        border-color: rgba(255,0,0,0.4);
        box-shadow: 0 0 0 3px rgba(255,0,0,0.08);
    }

    .search-form input[type=text]::placeholder { color: #444; }

    .search-form input[type=submit] {
        width: 100%;
        padding: 11px;
        background: var(--red);
        color: white;
        border: none;
        border-radius: 9px;
        font-family: 'DM Sans', sans-serif;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s, transform 0.15s;
        box-shadow: 0 3px 14px var(--red-glow);
    }

    .search-form input[type=submit]:hover {
        background: var(--red-dark);
        transform: translateY(-1px);
    }

    /* History list */
    .history-list {
        list-style: none;
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .history-list li a {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 9px 12px;
        border-radius: 8px;
        text-decoration: none;
        color: var(--text-muted);
        font-size: 13px;
        transition: all 0.15s;
        background: transparent;
    }

    .history-list li a:hover {
        background: var(--surface2);
        color: var(--text);
    }

    .history-list li a::before {
        content: '&#9679;';
        color: var(--red);
        font-size: 6px;
        flex-shrink: 0;
    }

    .history-time {
        font-size: 11px;
        color: #555;
        margin-left: auto;
        white-space: nowrap;
    }

    /* Main content */
    .main {
        padding: 32px;
        overflow-y: auto;
    }

    .main-empty {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 60vh;
        text-align: center;
        color: var(--text-muted);
    }

    .main-empty .empty-icon {
        width: 64px; height: 64px;
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 20px;
        font-size: 28px;
    }

    .main-empty h3 {
        font-family: 'Syne', sans-serif;
        font-size: 20px;
        font-weight: 700;
        color: var(--text);
        margin-bottom: 8px;
    }

    .main-empty p { font-size: 14px; }

    /* Results header */
    .results-header {
        margin-bottom: 24px;
    }

    .results-header h3 {
        font-family: 'Syne', sans-serif;
        font-size: 22px;
        font-weight: 700;
    }

    .results-header p {
        color: var(--text-muted);
        font-size: 14px;
        margin-top: 4px;
    }

    /* Video grid */
    .video-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
        gap: 20px;
    }

    .video-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 14px;
        overflow: hidden;
        transition: border-color 0.2s, transform 0.2s;
        animation: fadeIn 0.4s ease both;
    }

    .video-card:hover {
        border-color: rgba(255,0,0,0.3);
        transform: translateY(-3px);
        box-shadow: 0 12px 30px rgba(0,0,0,0.4);
    }

    .video-embed {
        width: 100%;
        aspect-ratio: 16/9;
        border: none;
        display: block;
    }

    .video-info {
        padding: 14px 16px;
    }

    .video-title {
        font-size: 14px;
        font-weight: 500;
        line-height: 1.45;
        margin-bottom: 8px;
        color: var(--text);
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .video-link a {
        font-size: 12px;
        color: var(--text-muted);
        text-decoration: none;
        transition: color 0.15s;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        display: block;
    }

    .video-link a:hover { color: var(--red); }

    .error-msg {
        background: rgba(255,0,0,0.1);
        border: 1px solid rgba(255,0,0,0.2);
        color: #ff6666;
        padding: 12px 16px;
        border-radius: 10px;
        font-size: 14px;
        margin-bottom: 16px;
    }

    @keyframes fadeIn {
        from { opacity:0; transform: translateY(10px); }
        to   { opacity:1; transform: translateY(0); }
    }

    @media (max-width: 768px) {
        .layout { grid-template-columns: 1fr; }
        .sidebar { border-right: none; border-bottom: 1px solid var(--border); }
    }
</style>
</head>
<body>

<nav class="topnav">
    <div class="nav-brand">
        <div class="nav-icon"></div>
        <span class="nav-title">VideoTut</span>
    </div>
    <div class="nav-right">
        <span class="user-badge">Signed in as <strong><%= uname %></strong></span>
        <a href="logout.jsp" class="logout-btn">Logout</a>
    </div>
</nav>

<div class="layout">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-section">
            <div class="sidebar-title">New Search</div>
            <form method="get" class="search-form">
                <input type="text" name="query" placeholder="e.g. Java Tutorials" required>
                <input type="submit" value="Search YouTube">
            </form>
        </div>

        <div class="sidebar-section">
            <div class="sidebar-title">Search History</div>
            <ul class="history-list">
                <%
                try{
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
                    PreparedStatement ps = con.prepareStatement("SELECT keyword, TO_CHAR(search_time,'DD-MON HH24:MI') AS tm FROM search_history WHERE user_id=? ORDER BY search_time DESC");
                    ps.setInt(1, uid);
                    ResultSet rs = ps.executeQuery();
                    while(rs.next()){
                        String kw = rs.getString("keyword");
                %>
                        <li>
                            <a href="dashboard.jsp?query=<%= kw %>">
                                <%= kw %>
                                <span class="history-time"><%= rs.getString("tm") %></span>
                            </a>
                        </li>
                <%
                    }
                    con.close();
                }catch(Exception e){ out.println("<li style='padding:8px;color:#666;font-size:13px;'>Error loading history: "+e+"</li>"); }
                %>
            </ul>
        </div>
    </aside>

    <!-- Main Results -->
    <main class="main">
        <%
        String query = request.getParameter("query");
        if(query != null && !query.trim().isEmpty()){

            // Save search to DB
            try{
                Class.forName("oracle.jdbc.driver.OracleDriver");
                Connection con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
                PreparedStatement ps = con.prepareStatement("INSERT INTO search_history VALUES(search_seq.NEXTVAL, ?, ?, SYSTIMESTAMP)");
                ps.setInt(1, uid);
                ps.setString(2, query);
                ps.executeUpdate();
                con.close();
            }catch(Exception e){ out.println("<div class='error-msg'>DB Error: "+e+"</div>"); }

            // YouTube API call
            String apiKey = "AIzaSyCmqvmdBu-XhnC3lTcIC3hjSu-SPIpKnL0";
            String encoded = URLEncoder.encode(query, "UTF-8");
            String urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=3&q="+encoded+"&key="+apiKey;

            try{
                URL url = new URL(urlString);
                HttpURLConnection conn = (HttpURLConnection)url.openConnection();
                conn.setRequestMethod("GET");
                conn.connect();

                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                StringBuilder sb = new StringBuilder();
                String line;
                while((line = br.readLine()) != null) sb.append(line);
                br.close();

                JSONObject json = new JSONObject(sb.toString());
                JSONArray items = json.getJSONArray("items");
        %>
                <div class="results-header">
                    <h3>Results for &ldquo;<%= query %>&rdquo;</h3>
                    <p><%= items.length() %> video(s) found</p>
                </div>
                <div class="video-grid">
        <%
                for(int i=0; i<items.length(); i++){
                    JSONObject v = items.getJSONObject(i);
                    String videoId = v.getJSONObject("id").getString("videoId");
                    String title = v.getJSONObject("snippet").getString("title");
                    String link = "https://www.youtube.com/watch?v=" + videoId;
        %>
                    <div class="video-card">
                        <iframe class="video-embed" src="https://www.youtube.com/embed/<%= videoId %>" allowfullscreen></iframe>
                        <div class="video-info">
                            <div class="video-title"><%= title %></div>
                            <div class="video-link"><a href="<%= link %>" target="_blank">&#9654; Watch on YouTube</a></div>
                        </div>
                    </div>
        <%
                }
        %>
                </div>
        <%
            }catch(Exception e){ out.println("<div class='error-msg'>API Error: "+e.getMessage()+"</div>"); }
        } else {
        %>
            <div class="main-empty">
                <div class="empty-icon">&#9654;</div>
                <h3>Search for videos</h3>
                <p>Enter a topic in the search bar to discover YouTube videos.</p>
            </div>
        <%
        }
        %>
    </main>
</div>

</body>
</html>
