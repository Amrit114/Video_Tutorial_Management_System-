<%@page import="videoTut.MyApi"%>
<%@ page import="java.io.*, java.net.*, org.json.*, java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>YouTube Search - VideoTut</title>
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
        gap: 14px;
    }

    .user-info {
        font-size: 13px;
        color: var(--text-muted);
    }

    .logout-link {
        font-size: 13px;
        color: var(--red);
        text-decoration: none;
        padding: 7px 14px;
        border-radius: 8px;
        border: 1px solid rgba(255,0,0,0.25);
        background: rgba(255,0,0,0.08);
        transition: background 0.2s;
    }

    .logout-link:hover { background: rgba(255,0,0,0.18); }

    /* Search bar */
    .search-bar {
        background: var(--surface);
        border-bottom: 1px solid var(--border);
        padding: 20px 32px;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .search-bar input[type="text"] {
        flex: 1;
        max-width: 520px;
        padding: 12px 18px;
        background: var(--surface2);
        border: 1px solid var(--border);
        border-radius: 10px;
        color: var(--text);
        font-family: 'DM Sans', sans-serif;
        font-size: 15px;
        outline: none;
        transition: border-color 0.2s, box-shadow 0.2s;
    }

    .search-bar input[type="text"]:focus {
        border-color: rgba(255,0,0,0.4);
        box-shadow: 0 0 0 3px rgba(255,0,0,0.08);
    }

    .search-bar input[type="text"]::placeholder { color: #444; }

    .search-bar input[type="submit"] {
        padding: 12px 24px;
        background: var(--red);
        color: white;
        border: none;
        border-radius: 10px;
        font-family: 'DM Sans', sans-serif;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s, transform 0.15s;
        box-shadow: 0 3px 14px var(--red-glow);
    }

    .search-bar input[type="submit"]:hover {
        background: var(--red-dark);
        transform: translateY(-1px);
    }

    /* Main */
    .main { padding: 32px; }

    .error-msg {
        background: rgba(255,0,0,0.1);
        border: 1px solid rgba(255,0,0,0.2);
        color: #ff6666;
        padding: 12px 16px;
        border-radius: 10px;
        font-size: 14px;
        margin-bottom: 20px;
    }

    .results-header {
        margin-bottom: 24px;
    }

    .results-header h2 {
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
    .video-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 20px;
    }

    .video {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 14px;
        overflow: hidden;
        transition: border-color 0.2s, transform 0.2s;
        animation: fadeIn 0.4s ease both;
    }

    .video:hover {
        border-color: rgba(255,0,0,0.3);
        transform: translateY(-3px);
        box-shadow: 0 12px 30px rgba(0,0,0,0.4);
    }

    .video iframe {
        width: 100%;
        aspect-ratio: 16/9;
        height: auto;
        border: none;
        border-radius: 0;
        display: block;
    }

    .video-meta {
        padding: 14px 16px;
    }

    .video h3 {
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

    .video p a {
        font-size: 12px;
        color: var(--text-muted);
        text-decoration: none;
        display: block;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        transition: color 0.15s;
    }

    .video p a:hover { color: var(--red); }

    .empty-state {
        text-align: center;
        padding: 80px 20px;
        color: var(--text-muted);
    }

    .empty-state h3 {
        font-family: 'Syne', sans-serif;
        font-size: 20px;
        color: var(--text);
        margin-bottom: 8px;
    }

    @keyframes fadeIn {
        from { opacity:0; transform: translateY(10px); }
        to   { opacity:1; transform: translateY(0); }
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
        <span class="user-info">Welcome, <%= session.getAttribute("uname") %></span>
        <a href="logout.jsp" class="logout-link">Logout</a>
    </div>
</nav>

<div class="search-bar">
    <form method="post" style="display:flex;gap:12px;width:100%;align-items:center;">
        <input type="text" name="query" placeholder="Search for any topic..." required>
        <input type="submit" value="Search">
    </form>
</div>

<%
Integer uid = (Integer)session.getAttribute("uid");
if(uid == null){
    response.sendRedirect("login.jsp");
    return;
}

String query = request.getParameter("query");
if(query != null && !query.trim().isEmpty()){
    // Save search info
    try{
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection con=DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
        PreparedStatement ps=con.prepareStatement("INSERT INTO search_history VALUES(search_seq.NEXTVAL, ?, ?, SYSTIMESTAMP)");
        ps.setInt(1, uid);
        ps.setString(2, query);
        ps.executeUpdate();
        con.close();
    }catch(Exception e){ out.println("<div class='error-msg'>DB Error: "+e+"</div>"); }

    // Fetch YouTube results
    String apiKey = MyApi.getAPI();
    String encoded = URLEncoder.encode(query, "UTF-8");
    String urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=6&q="+encoded+"&key="+apiKey;

    try{
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("GET");
        conn.connect();

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String line;
        while((line=br.readLine())!=null) sb.append(line);
        br.close();

        JSONObject json = new JSONObject(sb.toString());
        JSONArray items = json.getJSONArray("items");
%>
<div class="main">
    <div class="results-header">
        <h2>Results for &ldquo;<%= query %>&rdquo;</h2>
        <p><%= items.length() %> video(s) found</p>
    </div>
    <div class="video-container">
<%
        for(int i=0; i<items.length(); i++){
            JSONObject v = items.getJSONObject(i);
            String videoId = v.getJSONObject("id").getString("videoId");
            String title = v.getJSONObject("snippet").getString("title");
            String link = "https://www.youtube.com/watch?v="+videoId;
%>
            <div class="video">
                <iframe src="https://www.youtube.com/embed/<%= videoId %>" allowfullscreen></iframe>
                <div class="video-meta">
                    <h3><%= title %></h3>
                    <p><a href="<%= link %>" target="_blank">&#9654; Watch on YouTube</a></p>
                </div>
            </div>
<%
        }
%>
    </div>
</div>
<%
    }catch(Exception e){ out.println("<div class='main'><div class='error-msg'>API Error: "+e.getMessage()+"</div></div>"); }
} else {
%>
<div class="main">
    <div class="empty-state">
        <h3>Search for videos</h3>
        <p>Enter a keyword above to find YouTube videos instantly.</p>
    </div>
</div>
<% } %>

</body>
</html>
