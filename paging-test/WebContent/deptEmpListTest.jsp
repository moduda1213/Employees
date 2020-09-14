<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
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
		
		
		String ck =""; // 재직중인 사람들 체크
		if(request.getParameter("ck") != null){
			ck  = request.getParameter("ck");// ck ="yes"
		}
		System.out.println(ck+ "<--ck");
		
		String deptNo=""; //회사부서 등록 번호
		if(request.getParameter("deptNo") != null){
			deptNo=request.getParameter("deptNo");
		}
		System.out.println(deptNo+ "<--deptNo");
		
		Class.forName("org.mariadb.jdbc.Driver");
		Connection conn = DriverManager.getConnection(
				"jdbc:mariadb://127.0.0.1:3306/employees",
				"root",
				"java1004");
		String sql ="";
		String sql3= ""; // 조건에 따라 변하는 sql 문
		PreparedStatement stmt = null;
		PreparedStatement stmt3 = null; 
		
		int total=0; //총 데이터 양
		int lastPage =0; //총 데이터를 담을 페이지
		
		if(ck.equals("") && (deptNo.equals(""))){//둘다 선택을 하지 않았을 때
			sql ="select * from dept_emp order by emp_no desc limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1,beginRow);
			stmt.setInt(2,rowPerPage);
			
			sql3= "select count(*) from dept_emp"; // 총데이터 양
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
		}else if(ck.equals("") && (!deptNo.equals(""))){ //체크 안하고 이름만 일력되었을때
			sql ="select * from dept_emp where dept_no = ? order by emp_no desc limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1,deptNo);
			stmt.setInt(2,beginRow);
			stmt.setInt(3,rowPerPage);

			sql3= "select count(*) as cnt from dept_emp where dept_no=?"; //부서에 따른 데이터 양
			stmt3 = conn.prepareStatement(sql3);
			stmt3.setString(1,deptNo);
			ResultSet rs3 = stmt3.executeQuery();
			
			if(rs3.next()){
				total = rs3.getInt("cnt");
			}
			if(total % rowPerPage != 0){//나머지가 있을 때 페이지 +1
				lastPage = (total / rowPerPage)+1; 
			}else{ //나머지가 없을 때의 경우
				lastPage = (total / rowPerPage); 
			}
		}else if(ck.equals("yes") && (deptNo.equals(""))){ //체크 하고 이름은 입력안했을 때
			sql ="select * from dept_emp where to_date = '9999-01-01' order by emp_no desc limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setInt(1,beginRow);
			stmt.setInt(2,rowPerPage);
			
			sql3= "select count(*) as cnt from dept_emp where to_date = '9999-01-01'"; //은퇴 안한 직원의 총 수
			stmt3 = conn.prepareStatement(sql3);
			ResultSet rs3 = stmt3.executeQuery();
			
			if(rs3.next()){
				total = rs3.getInt("cnt");
			}
			if(total % rowPerPage != 0){//나머지가 있을 때 페이지 +1
				lastPage = (total / rowPerPage)+1; 
			}else{
				lastPage = (total / rowPerPage); 
			}
		}else{ //둘다 입력했을때
			sql ="select * from dept_emp where to_date = '9999-01-01' and dept_no =? order by emp_no desc limit ?,?";
			stmt = conn.prepareStatement(sql);
			stmt.setString(1,deptNo);
			stmt.setInt(2,beginRow);
			stmt.setInt(3,rowPerPage);
			
			sql3= "select count(*) as cnt from dept_emp where dept_no=? and to_date = '9999-01-01'"; // 두 조건 체크 되었을 때의 데이터양
			stmt3 = conn.prepareStatement(sql3);
			stmt3.setString(1,deptNo);
			ResultSet rs3 = stmt3.executeQuery();
			
			if(rs3.next()){
				total = rs3.getInt("cnt");
			}
			if(total % rowPerPage != 0){//나머지가 있을 때 페이지 +1
				lastPage = (total / rowPerPage)+1; 
			}else{
				lastPage = (total / rowPerPage); 
			}
		}
		
		System.out.println(total + "" +lastPage);
		ResultSet rs = stmt.executeQuery();
		
		String sql2 = "select dept_no from departments";
		PreparedStatement stmt2 = conn.prepareStatement(sql2);
		ResultSet rs2 = stmt2.executeQuery();
		
	%>
	
	<form action="./deptEmpList.jsp">
	
		<%
			if(ck.equals("")){ //체크 누른 후 검색하면 유지될 수 있도록
		%>
				<input type="checkbox" name ="ck" value="yes">현재 부서에 근무중
		<%
			}else{
		%>
				<input type="checkbox" name ="ck" value="yes" checked="checked">현재 부서에 근무중
		<%
			}
		%>
		<select name = "deptNo">
			<option value="">선택안함</option>
			<%
				while(rs2.next()){ 
					if(deptNo.equals(rs2.getString("dept_no"))){//dept_no 선택했을 때 유지
			%>
					<option value ='<%=rs2.getString("dept_no")%>' selected="selected"><%=rs2.getString("dept_no") %></option>
			<%
					}else{
			%>
						<option value ='<%=rs2.getString("dept_no")%>'><%=rs2.getString("dept_no") %></option>
			<%
					}
				}
			%>
		</select>
		<button type="submit">검색</button>
	</form>
	
	<table border="1">
		<tr>
			<th>emp_no</th>
			<th>dept_no</th>
			<th>from_date</th>
			<th>to_date</th>
		</tr>
		<%
			while(rs.next()){
		%>
				<tr>
					<td><%=rs.getInt("emp_no") %></td>
					<td><%=rs.getString("dept_no") %></td>
					<td><%=rs.getString("from_date") %></td>
					<td><%=rs.getString("to_date") %></td>
				</tr>	
		<%
			}
		%>
	</table>
	
	<table border ="1">
		<tr>
			<%
				if(currentPage>1){
			%>
					<td><a href="./deptEmpListTest.jsp?currentPage=1&deptNo=<%=deptNo%>&ck=<%=ck%>">처음으로</a></td>
					<td><a href="./deptEmpListTest.jsp?currentPage=<%=currentPage-1%>&deptNo=<%=deptNo%>&ck=<%=ck%>">이전</a></td>
			<%
				}
			%>
			<%
				if(currentPage < lastPage){
			%>
					<td><a href="./deptEmpListTest.jsp?currentPage=<%=currentPage+1%>&deptNo=<%=deptNo%>&ck=<%=ck%>">다음</a></td>
					<td><a href="./deptEmpListTest.jsp?currentPage=<%=lastPage%>&deptNo=<%=deptNo%>&ck=<%=ck%>">마지막으로</a></td>
			<%
				}
			%>
			
		</tr>
	</table>
</body>
</html>