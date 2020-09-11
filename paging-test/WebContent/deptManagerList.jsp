<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>employeesList</title>
</head>
<body>
	<%
		int currentPage = 1;
		if(request.getParameter("currentPage") != null){
			currentPage = Integer.parseInt(request.getParameter("currentPage"));
		}
		int rowPerPage = 10;
		Class.forName("org.mariadb.jdbc.Driver");
		
		Connection conn = DriverManager.getConnection(
				"jdbc:mariadb://127.0.0.1:3306/employees",
				"root",
				"java1004");
		String sql = "select * from dept_manager order by emp_no desc limit ?,?";
		PreparedStatement stmt = conn.prepareStatement(sql);
		stmt.setInt(1, (currentPage-1)*rowPerPage);
		stmt.setInt(2, rowPerPage);
		ResultSet rs = stmt.executeQuery();
	%>
	<h1>deptManagerList</h1>
	<div>
		<ul>
			<li><a href ="departmentsList.jsp">departmentsList</a></li>
			<li><a href ="deptEmpList.jsp">deptEmpList</a></li>
			<li><a>deptManagerList</a></li>
			<li><a href ="employeesList.jsp">employeesList</a></li>
			<li><a href ="salariesList.jsp">salariesList</a></li>
			<li><a href ="titlesList.jsp">titlesList</a></li>
		</ul>
	</div>
	<table border = "1">
		<thead>
			<tr>
				<th>emp_no</th>
				<th>from_date</th>
				<th>to_date</th>
			</tr>
		</thead>
		<tbody>
			<%
				while(rs.next()){
			%>
				<tr>
					<td><%=rs.getString("emp_no") %></td>
					<td><%=rs.getString("from_date") %></td>
					<td><%=rs.getString("to_date") %></td>
				</tr>
			<%
				
				}
			%>
		</tbody>
	</table>
	<!-- 페이징 네비게이션 -->
	<div>
			
		<%
			if(currentPage > 1){ // 1페이지에서 이전페이지는 없기 때문에
		%>
			<a href="./deptManagerList.jsp?currentPage=1">처음으로</a>
			<a href ="./deptManagerList.jsp?currentPage=<%=currentPage-1%>">이전</a>
		<%
			}
		%>
		<%
			String sql2 = "select count(*) from dept_manager";
			PreparedStatement stmt2 = conn.prepareStatement(sql2);
			ResultSet rs2 = stmt2.executeQuery();
			int totalCount = 0;
			if(rs2.next()) {
				totalCount = rs2.getInt("count(*)");
			}
			
			int lastPage = totalCount / rowPerPage;
			if(totalCount % rowPerPage != 0) { 
				// 나머지가 존재한다면 나머지를 보여주기 위해서 하나의 페이지가 더 필요하다
				lastPage += 1; // lastPage = lastPage+1
			}
			if(currentPage < lastPage) {
		%>
				<a href ="./deptManagerList.jsp?currentPage=<%=currentPage+1%>">다음</a>
				<a href="./deptManagerList.jsp?currentPage=<%=lastPage%>">마지막으로</a>
		<%
			}
		%>
		
			
		
			
	</div>
</body>
</html>