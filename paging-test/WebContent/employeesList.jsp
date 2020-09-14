<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>employeesList</title>
</head>
<body>
	<%
		request.setCharacterEncoding("utf-8");
	
		int currentPage = 1; //currentPage가 넘어오지 않으면 1
		if(request.getParameter("currentPage") != null){//currentPage가 넘어오면 대체하겠다
			currentPage = Integer.parseInt(request.getParameter("currentPage"));
		}
		
		int rowPerPage = 10; //페이지당 목록 수
		int beginRow = (currentPage-1)*rowPerPage; //불러올 시작 목록
		int total =0;
		int lastPage=0;
		
		String gender = "";
		if(request.getParameter("gender") != null) {
			gender = request.getParameter("gender");
		}
		String fullName = "";
		if(request.getParameter("fullName") != null) {
			fullName = request.getParameter("fullName");
		}
		
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection(
				"jdbc:mariadb://127.0.0.1:3306/employees",
				"root",
				"java1004");
		String sql ="";
		String sql3 ="";
		PreparedStatement stmt = null;
		PreparedStatement stmt3 = null;
		
		if(gender.equals("") && fullName.equals("")){
			sql = "select * from employees order by emp_no desc limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1, beginRow); 
			stmt.setInt(2, rowPerPage);
			
			sql3= "select count(*) from employees"; // 총데이터 양
			stmt3 = conn.prepareStatement(sql3);
			ResultSet rs3 = stmt3.executeQuery();
			if(rs3.next()){
				total = rs3.getInt("count(*)"); // 총 데이터 수
			}
			if(total % rowPerPage !=0){ //총 데이터를 담을 페이지 수
				lastPage = (total / rowPerPage)+1;		
			}else{
				lastPage = (total / rowPerPage); 
			}
			
		}else if(!gender.equals("") && fullName.equals("")){
			sql = "select * from employees where gender =? limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1,gender);
			stmt.setInt(2, beginRow); 
			stmt.setInt(3, rowPerPage);
			
			sql3= "select count(*) as cnt from employees where gender=?"; //부서에 따른 데이터 양
			stmt3 = conn.prepareStatement(sql3);
			stmt3.setString(1,gender);
			ResultSet rs3 = stmt3.executeQuery();
			
			if(rs3.next()){
				total = rs3.getInt("cnt");
			}
			if(total % rowPerPage != 0){//나머지가 있을 때 페이지 +1
				lastPage = (total / rowPerPage)+1; 
			}else{ //나머지가 없을 때의 경우
				lastPage = (total / rowPerPage); 
			}
		}else if(gender.equals("") && !fullName.equals("")){
			sql = "select * from employees where first_name like ? or last_name like ? limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1,"%"+fullName+"%");
			stmt.setString(2,"%"+fullName+"%");
			stmt.setInt(3, beginRow); 
			stmt.setInt(4, rowPerPage);
			
			sql3= "select count(*) as cnt from employees where first_name like ? or last_name like ?"; //부서에 따른 데이터 양
			stmt3 = conn.prepareStatement(sql3);
			stmt3.setString(1,"%"+fullName+"%");
			stmt3.setString(2,"%"+fullName+"%");
			ResultSet rs3 = stmt3.executeQuery();
			
			if(rs3.next()){
				total = rs3.getInt("cnt");
			}
			if(total % rowPerPage != 0){//나머지가 있을 때 페이지 +1
				lastPage = (total / rowPerPage)+1; 
			}else{ //나머지가 없을 때의 경우
				lastPage = (total / rowPerPage); 
			}
		}else{
			sql = "select * from employees where gender =? and (first_name like ? or last_name like ?) limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1,gender);
			stmt.setString(2,"%"+fullName+"%");
			stmt.setString(3,"%"+fullName+"%");
			stmt.setInt(4, beginRow); 
			stmt.setInt(5, rowPerPage);
			
			sql3= "select count(*) as cnt from employees where gender =? and (first_name like ? or last_name like ?)"; //부서에 따른 데이터 양
			stmt3 = conn.prepareStatement(sql3);
			stmt3.setString(1,gender);
			stmt3.setString(2,"%"+fullName+"%");
			stmt3.setString(3,"%"+fullName+"%");
			ResultSet rs3 = stmt3.executeQuery();
			
			if(rs3.next()){
				total = rs3.getInt("cnt");
			}
			if(total % rowPerPage != 0){//나머지가 있을 때 페이지 +1
				lastPage = (total / rowPerPage)+1; 
			}else{ //나머지가 없을 때의 경우
				lastPage = (total / rowPerPage); 
			}
		}
		ResultSet rs = stmt.executeQuery();
		//int count = (currentPage-1)*rowPerPage; 카운터를 주어서 최대 10번 
	%>
	<h1>employeesList</h1>
	<div>
		<ul>
			<li><a href ="departmentsList.jsp">departmentsList</a></li>
			<li><a href ="deptEmpList.jsp">deptEmpList</a></li>
			<li><a href ="deptManagerList.jsp">deptManagerList</a></li>
			<li><a>employeesList</a></li>
			<li><a href ="salariesList.jsp">salariesList</a></li>
			<li><a href ="titlesList.jsp">titlesList</a></li>
		</ul>
	</div>
	<table border="1">
		<thead>
			<tr>
				<th>emp_no</th>
				<th>birth_date</th>
				<th>first_name</th>
				<th>last_name</th>
				<th>gender</th>
				<th>hire_date</th>
			</tr>
		</thead>
		<tbody>
			<%
				while(rs.next()) {
			%>
					<tr>
						<td><%=rs.getInt("emp_no")%></td>
						<td><%=rs.getString("birth_date")%></td>
						<td><%=rs.getString("first_name")%></td>
						<td><%=rs.getString("last_name")%></td>
						<td><%=rs.getString("gender")%></td>
						<td><%=rs.getString("hire_date")%></td>
					</tr>
			<%	
				//count++;
				}
			%>
		</tbody>
	</table>
	
	<!-- 페이징 네비게이션 -->
	<div>
			
		<%
			if(currentPage > 1) {
		%>
			<a href="./employeesList.jsp?currentPage=1&gender=<%=gender%>&fullName=<%=fullName%>">처음으로</a>
			<a href="./employeesList.jsp?currentPage=<%=currentPage-1%>&gender=<%=gender%>&fullName=<%=fullName%>">이전</a>
		<%		
			}
		%>
		<%
			if(currentPage < lastPage) {
		%>
				<a href="./employeesList.jsp?currentPage=<%=currentPage+1%>&gender=<%=gender%>&fullName=<%=fullName%>">다음</a>
				<a href="./employeesList.jsp?currentPage=<%=lastPage%>&gender=<%=gender%>&fullName=<%=fullName%>">마지막으로</a>
		<%
			}
		%>
		
			<form method="post" action ="./employeesList.jsp?">
			나이<select name = "gender">
				<%
					if(gender.equals("")){
				%>
						<option value ="" selected="selected">상관없음</option>
						<option value ="M">남자</option>
						<option value ="F">여자</option>
				<%
					}else if(gender.equals("M")){
				%>
						<option value ="" >상관없음</option>
						<option value ="M" selected="selected">남자</option>
						<option value ="F">여자</option>
				<%	
					}else{
				%>
						<option value ="" >상관없음</option>
						<option value ="M">남자</option>
						<option value ="F" selected="selected">여자</option>
				<%
					}
				%>
				
			</select>
			<%
				if(fullName.equals("")){
			%>
					이름검색<input type = "text" name = "fullName">
			<%
				}else{
			%>
					이름검색<input type = "text" name = "fullName" value="<%=fullName %>">
			<%		
				}
			%>
			
			<button type ="submit">검색</button>
		</form>
		<div>&nbsp;</div>
	</div>
	
</body>
</html>
<!-- 이슈 : 첫페이지에서 처음으로 링크 안 나오게, 마지막 페이지에서 마지막으로 링크 안나오게 -->
