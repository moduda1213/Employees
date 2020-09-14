<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>employeeSearch</title>
</head>
<body>
	<%
		request.setCharacterEncoding("utf-8");
		
		//gender 
		String searchGender = "선택안함"; //선택안함 , 남 , 여
		if(request.getParameter("searchGender") != null){
			searchGender = request.getParameter("searchGender");
		}
		
		//firstName
		String searchFirstName = ""; // 이름
		
		if(request.getParameter("searchFirstName") != null){
			searchFirstName = request.getParameter("searchFirstName");
		}
		
		/*
			페이징 작업
			 lastPage :마지막 페이지, currentPage :현재 페이지, 
			onePerPage :한 페이지당 목록개수, totalData : 전체 사원 수
		*/
		//첫 페이지 이고 다음 페이지 숫자를 받을 때 저장
		int currentPage = 1;
		int onePerPage = 10; 
		if(request.getParameter("currentPage")!=null){
			currentPage = Integer.parseInt(request.getParameter("currentPage"));
		}
		
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection(
				"jdbc:mariadb://127.0.0.1:3306/employees",
				"root",
				"java1004");
		String sql ="";
		String sql2="";
		PreparedStatement stmt = null;
		PreparedStatement stmt2 = null;
		int beginPage = (currentPage-1)*onePerPage;//0~9, 10~19 .,,
		
		//동적쿼리 (쿼리의 경우의 수로 나눈다) 4 중 1택
		//searchGender  //searchFirstName
		//1. gender x , firstName x
		if(searchGender.equals("선택안함") && searchFirstName.equals("")){
			sql = "select * from employees limit ?,?"; //beginPage, onePerPage
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1,beginPage);
			stmt.setInt(2,onePerPage);
		//2. gender o , firstName x
		}else if(!searchGender.equals("선택안함") && searchFirstName.equals("")){ //!searchGender.equals("선택안함") : 선택안함이 아닐 때
			sql = "select * from employees where gender=? limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, searchGender);
			stmt.setInt(2,beginPage);
			stmt.setInt(3,onePerPage);
			
		
		//3. gender x , firstName o
		}else if(searchGender.equals("선택안함") && !searchFirstName.equals("")){
			sql = "select * from employees where first_name like ? limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1,"%"+searchFirstName+"%");
			stmt.setInt(2,beginPage);
			stmt.setInt(3,onePerPage);
		}else{
			sql = "select * from employees where gender = ? and first_name like ? limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1, searchGender);
			stmt.setString(2, "%"+searchFirstName+"%");
			stmt.setInt(3,beginPage);
			stmt.setInt(4,onePerPage);
		}
		
		ResultSet rs = stmt.executeQuery();
	%>
	<h1>사원 목록</h1>
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
				}
			%>
		</tbody>
	</table>
		
			<%
				if(currentPage > 1){
			%>
				<a href ="./employeeSearch.jsp?currentPage=1
				&searchGender=<%=searchGender%>&searchFirstName=<%=searchFirstName%>">처음으로</a>
				<a href ="./employeeSearch.jsp?currentPage=<%=currentPage-1 %>
				&searchGender=<%=searchGender%>&searchFirstName=<%=searchFirstName%>">이전</a>
			<%
				}
			%>
			<%
				int lastPage =0;
				if(searchGender.equals("선택안함") && searchFirstName.equals("")){
						 sql2 = "SELECT count(*) FROM employees";
						 stmt2 = conn.prepareStatement(sql2);
						 ResultSet rs2 = stmt2.executeQuery();
						
						int totalData = 0;
						if(rs2.next()){
								totalData =rs2.getInt("count(*)");
							}
						lastPage = totalData / onePerPage;//전체 개수에서 10를 나눈 값 +1
						if(totalData % onePerPage != 0){//나머지가 있다면 나머지 목록을 담을 페이지 하나 더 추가
								lastPage +=1;
							}		
				}else if(!searchGender.equals("선택안함") && searchFirstName.equals("")){
						 sql2 = "SELECT count(*) as cnt FROM employees WHERE gender =?";
						 stmt2 = conn.prepareStatement(sql2);
						 stmt2.setString(1,searchGender);
						 ResultSet rs2 = stmt2.executeQuery();
						
						int totalData = 0;
						if(rs2.next()){
								totalData =rs2.getInt("cnt");
							}
						lastPage = totalData / onePerPage;//전체 개수에서 10를 나눈 값 +1
						if(totalData % onePerPage != 0){//나머지가 있다면 나머지 목록을 담을 페이지 하나 더 추가
								lastPage +=1;
							}		
				}else if(searchGender.equals("선택안함") && !searchFirstName.equals("")){
						 sql2 = "SELECT count(*) as cnt FROM employees WHERE first_name LIKE ?";
						 stmt2 = conn.prepareStatement(sql2);
						 stmt2.setString(1,searchFirstName);
						 ResultSet rs2 = stmt2.executeQuery();
						
						int totalData = 0;
						if(rs2.next()){
								totalData =rs2.getInt("cnt");
							}
						lastPage = totalData / onePerPage;//전체 개수에서 10를 나눈 값 +1
						if(totalData % onePerPage != 0){//나머지가 있다면 나머지 목록을 담을 페이지 하나 더 추가
								lastPage +=1;
							}		
				}else{
					 sql2 = "SELECT count(*) as cnt FROM employees WHERE gender = ? AND first_name LIKE ?";
					 stmt2 = conn.prepareStatement(sql2);
					 stmt2.setString(1,searchGender);
					 stmt2.setString(2,searchFirstName);
					 ResultSet rs2 = stmt2.executeQuery();
						
						int totalData = 0;
						if(rs2.next()){
								totalData =rs2.getInt("cnt");
							}
						lastPage = totalData / onePerPage;//전체 개수에서 10를 나눈 값 +1
						if(totalData % onePerPage != 0){//나머지가 있다면 나머지 목록을 담을 페이지 하나 더 추가
								lastPage +=1;
							}		
				}
			
				
			%>
			<%
				if(currentPage < lastPage){
			%>
				<a href ="./employeeSearch.jsp?currentPage=<%=currentPage+1 %>
					&searchGender=<%=searchGender%>&searchFirstName=<%=searchFirstName%>">다음</a>
				<a href ="./employeeSearch.jsp?currentPage=<%=lastPage %>&searchGender=<%=searchGender%>
					&searchFirstName=<%=searchFirstName%>">마지막으로</a>
			<%
				}
			%>
				
	<form method ="post" action ="employeeSearch.jsp">
		<div>
			gender:
			<select name ="searchGender">
				<%
					if(searchGender.equals("선택안함")){
				%>
						<option value="선택안함" selected ="selected">선택안함</option>
				<%		
					}else{
				%>
						<option value="선택안함">선택안함</option>
				<%		
					}
				%>
				<%
					if(searchGender.equals("M")){
				%>
						<option value="M" selected ="selected">남</option>
				<%		
					}else{
				%>
						<option value="M">남</option>
				<%		
					}
				%>
				<%
					if(searchGender.equals("F")){
				%>
						<option value="F" selected ="selected">여</option>
				<%		
					}else{
				%>
						<option value="F">여</option>
				<%		
					}
				%>
				
			</select>
				
			first_name :
			<input type ="text" name = "searchFirstName" value = "<%=searchFirstName %>">
			
			<button type = "submit">검색</button>
		</div>
	</form>
	
</body>
</html>