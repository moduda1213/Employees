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
		String deptName = null;//입력값 가져오기
		
		if(request.getParameter("currentPage") != null){
			currentPage = Integer.parseInt(request.getParameter("currentPage"));
		}
		
		if(request.getParameter("deptName") != null){
			deptName = request.getParameter("deptName");
		}
		
		int rowPerPage = 10;
		Class.forName("org.mariadb.jdbc.Driver");
		
		Connection conn = DriverManager.getConnection(
				"jdbc:mariadb://127.0.0.1:3306/employees",
				"root",
				"java1004");
		
		
		
		
		PreparedStatement stmt= null;
		
		if(deptName != null){
			String sql = "select * from departments where dept_name LIKE ? limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1,"%"+deptName+"%");
			stmt.setInt(2, (currentPage-1)*rowPerPage);
			stmt.setInt(3, rowPerPage);
		}else{
			String sql = "select * from departments order by dept_no desc limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1, (currentPage-1)*rowPerPage);
			stmt.setInt(2, rowPerPage);
		}
		
		ResultSet rs = stmt.executeQuery();
		
	
		
	%>
	<h1>departmentsList</h1>
	<div>
		<ul>
			<li><a>departmentsList</a></li>
			<li><a href ="deptEmpList.jsp">deptEmpList</a></li>
			<li><a href ="deptManagerList.jsp">deptManagerList</a></li>
			<li><a href ="employeesList.jsp">employeesList</a></li>
			<li><a href ="salariesList.jsp">salariesList</a></li>
			<li><a href ="titlesList.jsp">titlesList</a></li>
		</ul>
	</div>
	
	<table border = "1">
		<thead>
			<tr>
				<th>dept_no</th>
				<th>dept_name</th>
			</tr>
		</thead>
		<tbody>
			<%
				while(rs.next()){
			%>
				<tr>
					<td><%=rs.getString("dept_no") %></td>
					<td><%=rs.getString("dept_name") %></td>
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
			<a href="./departmentsList.jsp?currentPage=1">처음으로</a>
			<a href ="./departmentsList.jsp?currentPage=<%=currentPage-1%>">이전</a>
		<%
			}
		%>
			
		<%
			String sql2 = "select count(*) from departments";
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
				<a href ="./departmentsList.jsp?currentPage=<%=currentPage+1%>">다음</a>
				<a href="./departmentsList.jsp?currentPage=<%=lastPage%>">마지막으로</a>
		<%
			}
		%>
	</div>
	
		<div>&nbsp;</div>
		<div>
			<form method="post" action="./departmentsList.jsp">
				부서이름<input type = "text" name = "deptName">
				<button type ="submit">검색</button>
			</form>
		</div>
</body>
</html>