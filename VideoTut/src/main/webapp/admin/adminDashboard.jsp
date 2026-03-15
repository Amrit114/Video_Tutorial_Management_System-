<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ page import="java.sql.*" %>
<%
    String admin = (String)session.getAttribute("admin");
    if(admin == null){ response.sendRedirect("adminLogin.jsp"); return; }

    /* ------ Handle POST Actions --------------------------------------------------------------------------------------------------------------------------------- */
    String action = request.getParameter("action");
    String flashMsg = "", flashType = "";
    Connection con = null;
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");

        if("deleteOne".equals(action)){
            PreparedStatement p = con.prepareStatement("DELETE FROM search_history WHERE id=?");
            p.setInt(1, Integer.parseInt(request.getParameter("hid")));
            p.executeUpdate(); p.close();
            flashMsg = "[OK] Record deleted."; flashType = "success";
        }
        else if("deleteUserHistory".equals(action)){
            PreparedStatement p = con.prepareStatement("DELETE FROM search_history WHERE user_id=?");
            p.setInt(1, Integer.parseInt(request.getParameter("uid")));
            p.executeUpdate(); p.close();
            flashMsg = "[OK] User history cleared."; flashType = "success";
        }
        else if("deleteAll".equals(action)){
            con.createStatement().executeUpdate("DELETE FROM search_history");
            flashMsg = "[!] All search history wiped."; flashType = "warning";
        }
        else if("deleteUser".equals(action)){
            int uid = Integer.parseInt(request.getParameter("uid"));
            PreparedStatement p1 = con.prepareStatement("DELETE FROM search_history WHERE user_id=?");
            p1.setInt(1, uid); p1.executeUpdate(); p1.close();
            PreparedStatement p2 = con.prepareStatement("DELETE FROM vdusers WHERE id=?");
            p2.setInt(1, uid); p2.executeUpdate(); p2.close();
            flashMsg = "[OK] User account and history deleted."; flashType = "danger";
        }
    } catch(Exception e){
        flashMsg = "[X] Error: " + e.getMessage(); flashType = "error";
    } finally { if(con!=null) try{con.close();}catch(Exception e){} }

    /* ------ Stats --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
    int totalUsers=0, totalSearches=0, todaySearches=0;
    String topKeyword="--";
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
        ResultSet rs;
        rs = con.createStatement().executeQuery("SELECT COUNT(*) FROM vdusers");
        if(rs.next()) totalUsers=rs.getInt(1); rs.close();
        rs = con.createStatement().executeQuery("SELECT COUNT(*) FROM search_history");
        if(rs.next()) totalSearches=rs.getInt(1); rs.close();
        rs = con.createStatement().executeQuery("SELECT COUNT(*) FROM search_history WHERE TRUNC(search_time)=TRUNC(SYSDATE)");
        if(rs.next()) todaySearches=rs.getInt(1); rs.close();
        rs = con.createStatement().executeQuery(
            "SELECT keyword FROM (SELECT keyword,COUNT(*) c FROM search_history GROUP BY keyword ORDER BY c DESC) WHERE ROWNUM=1");
        if(rs.next()) topKeyword=rs.getString(1); rs.close();
    } catch(Exception e){} finally { if(con!=null) try{con.close();}catch(Exception e){} }

    /* ------ Chart Data ------------------------------------------------------------------------------------------------------------------------------------------------------------ */
    StringBuilder userData  = new StringBuilder("[['User','Search Count']");
    StringBuilder topicData = new StringBuilder("[['Topic','Search Count']");
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
        ResultSet r1 = con.createStatement().executeQuery(
            "SELECT u.name, COUNT(s.id) AS c FROM vdusers u LEFT JOIN search_history s ON u.id=s.user_id GROUP BY u.name ORDER BY c DESC");
        while(r1.next()) userData.append(",['").append(r1.getString("name").replace("'","\\'")).append("',").append(r1.getInt("c")).append("]");
        r1.close();
        ResultSet r2 = con.createStatement().executeQuery(
            "SELECT * FROM (SELECT keyword,COUNT(*) cnt FROM search_history GROUP BY keyword ORDER BY cnt DESC) WHERE ROWNUM<=5");
        while(r2.next()) topicData.append(",['").append(r2.getString("keyword").replace("'","\\'")).append("',").append(r2.getInt("cnt")).append("]");
        r2.close();
    } catch(Exception e){} finally { if(con!=null) try{con.close();}catch(Exception e){} }
    userData.append("]"); topicData.append("]");

    /* ------ Filters --------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
    String filterUser    = request.getParameter("filterUser");    if(filterUser==null) filterUser="";
    String filterKeyword = request.getParameter("filterKeyword"); if(filterKeyword==null) filterKeyword="";
    String activeTab     = request.getParameter("tab");           if(activeTab==null) activeTab="overview";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard - VideoTut</title>
<script src="https://www.gstatic.com/charts/loader.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
<style>
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box;}
:root{
    --red:#FF0000;--red-dark:#CC0000;--red-glow:rgba(255,0,0,0.2);
    --bg:#0A0A0A;--surface:#141414;--surface2:#1C1C1C;
    --text:#F5F5F5;--muted:#777;--border:rgba(255,255,255,0.08);
    --green:#22c55e;--green-bg:rgba(34,197,94,0.1);--green-bd:rgba(34,197,94,0.25);
    --amber:#f59e0b;--amber-bg:rgba(245,158,11,0.1);--amber-bd:rgba(245,158,11,0.25);
    --blue:#3b82f6;--blue-bg:rgba(59,130,246,0.1);--blue-bd:rgba(59,130,246,0.25);
}
body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;}

/* NAV */
.topnav{background:var(--surface);border-bottom:1px solid var(--border);padding:0 28px;height:60px;
    display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:200;}
.nav-brand{display:flex;align-items:center;gap:10px;}
.nav-icon{width:32px;height:22px;background:var(--red);border-radius:5px;display:flex;
    align-items:center;justify-content:center;box-shadow:0 2px 8px var(--red-glow);}
.nav-icon::after{content:'';border-left:9px solid white;border-top:5px solid transparent;border-bottom:5px solid transparent;margin-left:2px;}
.nav-title{font-family:'Syne',sans-serif;font-weight:800;font-size:16px;}
.nav-right{display:flex;align-items:center;gap:12px;}
.admin-chip{display:flex;align-items:center;gap:7px;background:rgba(255,0,0,0.1);border:1px solid rgba(255,0,0,0.2);
    padding:5px 12px;border-radius:20px;font-size:13px;color:#ff8888;}
.chip-dot{width:7px;height:7px;background:var(--red);border-radius:50%;animation:pulse 1.5s infinite;}
.logout-btn{text-decoration:none;background:var(--surface2);color:var(--muted);border:1px solid var(--border);
    padding:7px 16px;border-radius:8px;font-size:13px;transition:all .2s;}
.logout-btn:hover{color:var(--text);background:#252525;}

/* TABS */
.tabs{background:var(--surface);border-bottom:1px solid var(--border);display:flex;padding:0 28px;gap:2px;}
.tab-btn{background:none;border:none;border-bottom:2px solid transparent;color:var(--muted);
    font-family:'DM Sans',sans-serif;font-size:13px;font-weight:500;padding:14px 18px;
    cursor:pointer;transition:all .2s;white-space:nowrap;}
.tab-btn:hover{color:var(--text);}
.tab-btn.active{color:var(--red);border-bottom-color:var(--red);}

/* MAIN + PANELS */
.main{padding:28px;max-width:1400px;margin:0 auto;}
.tab-panel{display:none;animation:fadeIn .3s ease;}
.tab-panel.active{display:block;}
.section-label{font-size:11px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:1px;margin-bottom:14px;}

/* FLASH */
.flash{padding:13px 18px;border-radius:10px;font-size:14px;margin-bottom:24px;display:flex;align-items:center;gap:10px;animation:fadeIn .3s ease;}
.flash.success{background:var(--green-bg);border:1px solid var(--green-bd);color:#86efac;}
.flash.warning{background:var(--amber-bg);border:1px solid var(--amber-bd);color:#fcd34d;}
.flash.danger,.flash.error{background:rgba(255,0,0,0.08);border:1px solid rgba(255,0,0,0.2);color:#ff8888;}

/* STAT CARDS */
.stat-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:28px;}
.stat-card{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:22px 24px;
    display:flex;flex-direction:column;gap:10px;transition:border-color .2s,transform .2s;}
.stat-card:hover{border-color:rgba(255,255,255,0.15);transform:translateY(-2px);}
.stat-card.hot{border-color:rgba(255,0,0,0.2);background:rgba(255,0,0,0.03);}
.stat-top{display:flex;align-items:center;justify-content:space-between;}
.stat-icon{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:17px;}
.stat-icon.red{background:rgba(255,0,0,0.12);}
.stat-icon.green{background:var(--green-bg);}
.stat-icon.amber{background:var(--amber-bg);}
.stat-icon.blue{background:var(--blue-bg);}
.stat-label{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;}
.stat-value{font-family:'Syne',sans-serif;font-size:32px;font-weight:800;line-height:1;}
.stat-sub{font-size:12px;color:var(--muted);}

/* CHARTS */
.chart-grid{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:28px;}
.chart-box{background:var(--surface);border:1px solid var(--border);border-radius:14px;padding:24px;overflow:hidden;}
.chart-box-title{font-family:'Syne',sans-serif;font-size:15px;font-weight:700;margin-bottom:16px;}
#userChart,#topicChart{width:100%;height:300px;}

/* CARD */
.card{background:var(--surface);border:1px solid var(--border);border-radius:14px;overflow:hidden;margin-bottom:20px;}
.card-header{padding:18px 22px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;}
.card-header h3{font-family:'Syne',sans-serif;font-size:16px;font-weight:700;}
.card-actions{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}

/* FILTER */
.filter-bar{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}
.filter-bar input[type=text]{padding:8px 14px;background:var(--surface2);border:1px solid var(--border);
    border-radius:8px;color:var(--text);font-family:'DM Sans',sans-serif;font-size:13px;outline:none;
    transition:border-color .2s;min-width:160px;}
.filter-bar input[type=text]:focus{border-color:rgba(255,0,0,0.4);}
.filter-bar input::placeholder{color:#444;}

/* BUTTONS */
.btn{display:inline-flex;align-items:center;gap:6px;padding:8px 16px;border-radius:8px;
    font-family:'DM Sans',sans-serif;font-size:13px;font-weight:500;cursor:pointer;
    border:none;text-decoration:none;transition:all .2s;white-space:nowrap;}
.btn-sm{padding:6px 12px;font-size:12px;border-radius:7px;}
.btn-red{background:rgba(255,0,0,0.1);color:#ff8888;border:1px solid rgba(255,0,0,0.2);}
.btn-red:hover{background:rgba(255,0,0,0.2);color:var(--text);}
.btn-danger{background:var(--red);color:white;box-shadow:0 3px 12px var(--red-glow);}
.btn-danger:hover{background:var(--red-dark);}
.btn-green{background:var(--green-bg);color:#86efac;border:1px solid var(--green-bd);}
.btn-green:hover{background:rgba(34,197,94,0.2);}
.btn-blue{background:var(--blue-bg);color:#93c5fd;border:1px solid var(--blue-bd);}
.btn-blue:hover{background:rgba(59,130,246,0.2);}
.btn-ghost{background:var(--surface2);color:var(--muted);border:1px solid var(--border);}
.btn-ghost:hover{color:var(--text);}

/* TABLE */
.table-wrap{overflow-x:auto;}
table{width:100%;border-collapse:collapse;}
thead th{background:var(--surface2);padding:12px 18px;text-align:left;font-size:11px;
    font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.8px;border-bottom:1px solid var(--border);}
tbody td{padding:13px 18px;font-size:14px;color:var(--muted);border-bottom:1px solid var(--border);vertical-align:middle;}
tbody tr:last-child td{border-bottom:none;}
tbody tr:hover td{background:rgba(255,255,255,0.02);color:var(--text);}
.empty-row td{text-align:center;padding:40px;color:#444;font-size:14px;}
.kw-tag{display:inline-block;background:rgba(255,0,0,0.08);border:1px solid rgba(255,0,0,0.15);
    color:#ff9999;padding:3px 10px;border-radius:6px;font-size:13px;}
.time-mono{font-family:monospace;font-size:12px;color:#555;}
.row-num{font-size:12px;color:#444;}
.user-avatar{display:inline-flex;align-items:center;justify-content:center;
    width:30px;height:30px;border-radius:50%;background:rgba(255,0,0,0.15);
    color:#ff8888;font-size:11px;font-weight:700;margin-right:8px;vertical-align:middle;}
.user-name{font-weight:500;color:var(--text);vertical-align:middle;}
.user-email{font-size:13px;color:var(--muted);}
.table-footer{padding:12px 18px;font-size:12px;color:var(--muted);border-top:1px solid var(--border);}

/* MODAL */
.modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,0.75);backdrop-filter:blur(4px);
    display:none;align-items:center;justify-content:center;z-index:999;}
.modal-overlay.open{display:flex;}
.modal{background:var(--surface);border:1px solid var(--border);border-radius:16px;padding:32px;
    max-width:420px;width:90%;box-shadow:0 24px 60px rgba(0,0,0,.6);animation:slideUp .3s ease;}
.modal h3{font-family:'Syne',sans-serif;font-size:20px;font-weight:700;margin-bottom:12px;}
.modal p{font-size:14px;color:var(--muted);line-height:1.7;margin-bottom:24px;}
.modal p strong{color:var(--text);}
.modal-actions{display:flex;gap:10px;justify-content:flex-end;}

@keyframes pulse{0%,100%{opacity:1;}50%{opacity:.3;}}
@keyframes fadeIn{from{opacity:0;}to{opacity:1;}}
@keyframes slideUp{from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:translateY(0);}}
@media(max-width:900px){.stat-grid{grid-template-columns:1fr 1fr;}.chart-grid{grid-template-columns:1fr;}}
@media(max-width:600px){.stat-grid{grid-template-columns:1fr;}
    .card-header{flex-direction:column;align-items:flex-start;}
    .card-actions{width:100%;}}
</style>
</head>
<body>

<!-- ------ NAV ------ -->
<nav class="topnav">
    <div class="nav-brand">
        <div class="nav-icon"></div>
        <span class="nav-title">VideoTut Admin</span>
    </div>
    <div class="nav-right">
        <div class="admin-chip"><div class="chip-dot"></div><%= admin %></div>
        <a href="../logout.jsp" class="logout-btn">Logout</a>
    </div>
</nav>

<!-- ------ TABS ------ -->
<div class="tabs">
    <button class="tab-btn <%= "overview".equals(activeTab)?"active":"" %>" onclick="switchTab('overview',this)">Overview</button>
    <button class="tab-btn <%= "history".equals(activeTab)?"active":"" %>"  onclick="switchTab('history',this)">Search History</button>
    <button class="tab-btn <%= "users".equals(activeTab)?"active":"" %>"    onclick="switchTab('users',this)">Users</button>
</div>

<div class="main">

    <!-- FLASH -->
    <% if(!flashMsg.isEmpty()){ %>
    <div class="flash <%= flashType %>"><%= flashMsg %></div>
    <% } %>

    <!-- ---------------------------------------------------------------------------------
         PANEL 1 -- OVERVIEW
    --------------------------------------------------------------------------------- -->
    <div id="tab-overview" class="tab-panel <%= "overview".equals(activeTab)?"active":"" %>">

        <div class="stat-grid">
            <div class="stat-card">
                <div class="stat-top">
                    <span class="stat-label">Total Users</span>
                    <span class="stat-icon blue">U</span>
                </div>
                <div class="stat-value"><%= totalUsers %></div>
                <div class="stat-sub">Registered accounts</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <span class="stat-label">Total Searches</span>
                    <span class="stat-icon red">S</span>
                </div>
                <div class="stat-value"><%= totalSearches %></div>
                <div class="stat-sub">All-time records</div>
            </div>
            <div class="stat-card">
                <div class="stat-top">
                    <span class="stat-label">Today</span>
                    <span class="stat-icon green">T</span>
                </div>
                <div class="stat-value"><%= todaySearches %></div>
                <div class="stat-sub">Searches today</div>
            </div>
            <div class="stat-card hot">
                <div class="stat-top">
                    <span class="stat-label">Trending</span>
                    <span class="stat-icon amber">*</span>
                </div>
                <div class="stat-value" style="font-size:18px;word-break:break-word;line-height:1.3;"><%= topKeyword %></div>
                <div class="stat-sub">Top searched keyword</div>
            </div>
        </div>

        <div class="section-label">Analytics Charts</div>
        <div class="chart-grid">
            <div class="chart-box">
                <div class="chart-box-title">User-wise Total Searches</div>
                <div id="userChart"></div>
            </div>
            <div class="chart-box">
                <div class="chart-box-title">Top 5 Most Searched Topics</div>
                <div id="topicChart"></div>
            </div>
        </div>

    </div>

    <!-- ---------------------------------------------------------------------------------
         PANEL 2 -- SEARCH HISTORY
    --------------------------------------------------------------------------------- -->
    <div id="tab-history" class="tab-panel <%= "history".equals(activeTab)?"active":"" %>">
        <div class="card">
            <div class="card-header">
                <h3>Search History Logs</h3>
                <div class="card-actions">
                    <form method="get" action="adminDashboard.jsp" class="filter-bar">
                        <input type="hidden" name="tab" value="history">
                        <input type="text" name="filterUser" placeholder="Filter by user" value="<%= filterUser %>">
                        <input type="text" name="filterKeyword" placeholder="Filter by keyword" value="<%= filterKeyword %>">
                        <button type="submit" class="btn btn-ghost btn-sm">Apply</button>
                        <% if(!filterUser.isEmpty()||!filterKeyword.isEmpty()){ %>
                        <a href="adminDashboard.jsp?tab=history" class="btn btn-ghost btn-sm">Clear</a>
                        <% } %>
                    </form>
                    <button class="btn btn-blue btn-sm" onclick="exportCSV()">Export CSV</button>
                    <button class="btn btn-danger btn-sm" onclick="openModal('modalDeleteAll')">Delete All</button>
                </div>
            </div>

            <div class="table-wrap">
            <table id="historyTable">
                <thead>
                    <tr>
                        <th>#</th><th>User</th><th>Keyword</th><th>Search Time</th><th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                int rowNum = 0;
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
                    StringBuilder q = new StringBuilder(
                        "SELECT s.id, u.name, s.keyword, TO_CHAR(s.search_time,'DD-MON-YYYY HH24:MI:SS') AS tm " +
                        "FROM search_history s JOIN vdusers u ON s.user_id=u.id WHERE 1=1");
                    if(!filterUser.isEmpty())
                        q.append(" AND LOWER(u.name) LIKE LOWER('%").append(filterUser.replace("'","''")).append("%')");
                    if(!filterKeyword.isEmpty())
                        q.append(" AND LOWER(s.keyword) LIKE LOWER('%").append(filterKeyword.replace("'","''")).append("%')");
                    q.append(" ORDER BY s.search_time DESC");
                    ResultSet rs = con.createStatement().executeQuery(q.toString());
                    while(rs.next()){
                        rowNum++;
                        int hid = rs.getInt("id");
                %>
                    <tr>
                        <td class="row-num"><%= rowNum %></td>
                        <td><%= rs.getString("name") %></td>
                        <td><span class="kw-tag"><%= rs.getString("keyword") %></span></td>
                        <td><span class="time-mono"><%= rs.getString("tm") %></span></td>
                        <td>
                            <form method="post" action="adminDashboard.jsp?tab=history" style="display:inline;">
                                <input type="hidden" name="action" value="deleteOne">
                                <input type="hidden" name="hid" value="<%= hid %>">
                                <button type="submit" class="btn btn-red btn-sm"
                                    onclick="return confirm('Delete this record?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                <%
                    }
                    if(rowNum==0){
                %><tr class="empty-row"><td colspan="5">No records found.</td></tr><%
                    }
                    rs.close();
                } catch(Exception e){
                    out.println("<tr><td colspan='5' style='color:#ff6666;padding:16px;'>Error: "+e.getMessage()+"</td></tr>");
                } finally { if(con!=null) try{con.close();}catch(Exception e){} }
                %>
                </tbody>
            </table>
            </div>
            <div class="table-footer">
                Showing <strong style="color:var(--text)"><%= rowNum %></strong> record(s)
                <% if(!filterUser.isEmpty()||!filterKeyword.isEmpty()){ %>&nbsp;&mdash; filtered<% } %>
            </div>
        </div>
    </div>

    <!-- ---------------------------------------------------------------------------------
         PANEL 3 -- USERS
    --------------------------------------------------------------------------------- -->
    <div id="tab-users" class="tab-panel <%= "users".equals(activeTab)?"active":"" %>">
        <div class="card">
            <div class="card-header">
                <h3>Registered Users</h3>
            </div>
            <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>#</th><th>Name</th><th>Email</th><th>Searches</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                int uRowNum = 0;
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","system");
                    ResultSet rs = con.createStatement().executeQuery(
                        "SELECT u.id, u.name, u.email, COUNT(s.id) AS sc " +
                        "FROM vdusers u LEFT JOIN search_history s ON u.id=s.user_id " +
                        "GROUP BY u.id, u.name, u.email ORDER BY sc DESC");
                    while(rs.next()){
                        uRowNum++;
                        int uid   = rs.getInt("id");
                        String nm = rs.getString("name");
                        String em = rs.getString("email");
                        int sc    = rs.getInt("sc");
                        String initials = nm.length()>=2 ? nm.substring(0,2).toUpperCase() : nm.toUpperCase();
                %>
                    <tr>
                        <td class="row-num"><%= uRowNum %></td>
                        <td>
                            <span class="user-avatar"><%= initials %></span>
                            <span class="user-name"><%= nm %></span>
                        </td>
                        <td><span class="user-email"><%= em %></span></td>
                        <td>
                            <span style="font-family:'Syne',sans-serif;font-weight:700;font-size:15px;color:var(--text)"><%= sc %></span>
                            <span style="font-size:12px;color:var(--muted);"> searches</span>
                        </td>
                        <td>
                            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                <form method="post" action="adminDashboard.jsp?tab=users" style="display:inline;">
                                    <input type="hidden" name="action" value="deleteUserHistory">
                                    <input type="hidden" name="uid" value="<%= uid %>">
                                    <button type="submit" class="btn btn-red btn-sm"
                                        onclick="return confirm('Clear all history for <%= nm %>?')">
                                        Clear History
                                    </button>
                                </form>
                                <form method="post" action="adminDashboard.jsp?tab=users" style="display:inline;">
                                    <input type="hidden" name="action" value="deleteUser">
                                    <input type="hidden" name="uid" value="<%= uid %>">
                                    <button type="submit" class="btn btn-danger btn-sm"
                                        onclick="return confirm('PERMANENTLY delete user <%= nm %> and ALL their data? This cannot be undone.')">
                                        Delete User
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                <%
                    }
                    if(uRowNum==0){
                %><tr class="empty-row"><td colspan="5">No users registered yet.</td></tr><%
                    }
                    rs.close();
                } catch(Exception e){
                    out.println("<tr><td colspan='5' style='color:#ff6666;padding:16px;'>Error: "+e.getMessage()+"</td></tr>");
                } finally { if(con!=null) try{con.close();}catch(Exception e){} }
                %>
                </tbody>
            </table>
            </div>
            <div class="table-footer"><strong style="color:var(--text)"><%= uRowNum %></strong> registered users</div>
        </div>
    </div>

</div><!-- /main -->

<!-- MODAL: Confirm Delete All -->
<div class="modal-overlay" id="modalDeleteAll">
    <div class="modal">
        <h3>Delete All History?</h3>
        <p>This will permanently erase <strong>every search record</strong> from the database.<br>This action <strong>cannot be undone</strong>.</p>
        <div class="modal-actions">
            <button class="btn btn-ghost" onclick="closeModal('modalDeleteAll')">Cancel</button>
            <form method="post" action="adminDashboard.jsp?tab=history" style="display:inline;">
                <input type="hidden" name="action" value="deleteAll">
                <button type="submit" class="btn btn-danger">Yes, Delete All</button>
            </form>
        </div>
    </div>
</div>

<!-- GOOGLE CHARTS + JS -->
<script>
google.charts.load('current',{'packages':['corechart','bar']});
google.charts.setOnLoadCallback(function(){
    var ud = google.visualization.arrayToDataTable(<%= userData %>);
    var uc = ['#FF6384','#36A2EB','#FFCE56','#4BC0C0','#9966FF','#FF9F40','#00A86B'];
    while(uc.length < ud.getNumberOfRows()) uc.push('#'+Math.floor(Math.random()*16777215).toString(16));
    new google.visualization.PieChart(document.getElementById('userChart')).draw(ud,{
        pieHole:0.4, colors:uc, backgroundColor:'transparent',
        legend:{textStyle:{color:'#888',fontSize:12}},
        chartArea:{width:'85%',height:'85%'}
    });

    var td = google.visualization.arrayToDataTable(<%= topicData %>);
    new google.visualization.BarChart(document.getElementById('topicChart')).draw(td,{
        chartArea:{width:'62%',height:'80%'},
        hAxis:{title:'Count',textStyle:{color:'#888'},titleTextStyle:{color:'#888'},gridlines:{color:'#1e1e1e'}},
        vAxis:{textStyle:{color:'#888'}},
        backgroundColor:'transparent', legend:{position:'none'},
        colors:['#FF0000','#FF5733','#FF6B35','#CC0000','#FF3333']
    });
});

// TAB SWITCHER
function switchTab(name, btn){
    document.querySelectorAll('.tab-panel').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-'+name).classList.add('active');
    btn.classList.add('active');
}

// MODAL
function openModal(id){ document.getElementById(id).classList.add('open'); }
function closeModal(id){ document.getElementById(id).classList.remove('open'); }
document.querySelectorAll('.modal-overlay').forEach(m => {
    m.addEventListener('click', function(e){ if(e.target===this) this.classList.remove('open'); });
});

// EXPORT CSV
function exportCSV(){
    var rows = [['#','User','Keyword','Search Time']];
    document.querySelectorAll('#historyTable tbody tr').forEach(function(tr){
        var cells = tr.querySelectorAll('td');
        if(cells.length >= 4){
            rows.push([cells[0].innerText.trim(), cells[1].innerText.trim(),
                       cells[2].innerText.trim(), cells[3].innerText.trim()]);
        }
    });
    var csv = rows.map(r => r.map(c => '"'+c.replace(/"/g,'""')+'"').join(',')).join('\n');
    var a = document.createElement('a');
    a.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
    a.download = 'search_history_export.csv';
    a.click();
}
</script>

</body>
</html>
