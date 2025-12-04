# 로그인 세션 사용 가이드

## 목차
1. [세션에 저장된 정보](#1-세션에-저장된-정보)
2. [JSP에서 세션 정보 사용하기](#2-jsp에서-세션-정보-사용하기)
3. [Servlet에서 세션 정보 사용하기](#3-servlet에서-세션-정보-사용하기)
4. [DAO에서 현재 로그인한 학생 정보 사용하기](#4-dao에서-현재-로그인한-학생-정보-사용하기)
5. [주의사항](#5-주의사항)
6. [예제: 내 수강신청 목록 조회](#6-예제-내-수강신청-목록-조회)
7. [빠른 참조](#7-빠른-참조)
8. [문제 해결](#8-문제-해결)

---

## 1. 세션에 저장된 정보

로그인 성공 시 다음 정보가 세션에 저장됩니다:
- `studentId` (Integer): 학생 학번
- `studentName` (String): 학생 이름

---

## 2. JSP에서 세션 정보 사용하기

### 기본 사용법
```jsp
<%
    // 세션에서 정보 가져오기
    Integer studentId = (Integer) session.getAttribute("studentId");
    String studentName = (String) session.getAttribute("studentName");
    
    // 로그인 체크 (null이면 로그인 안 됨)
    if (studentId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>내 페이지</title>
</head>
<body>
    <h1><%= studentName %>님 환영합니다!</h1>
    <p>학번: <%= studentId %></p>
</body>
</html>
```

### 로그인 체크만 하는 경우
```jsp
<%
    // 로그인 안 되어 있으면 로그인 페이지로
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
```

### loginCheck.jsp 사용하기
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/loginCheck.jsp" %>
<%
    String studentName = (String) session.getAttribute("studentName");
%>
```

---

## 3. Servlet에서 세션 정보 사용하기

```java
@WebServlet("/mypage")
public class MyPageServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. 세션 가져오기
        HttpSession session = request.getSession(false);
        
        // 2. 로그인 체크
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // 3. 세션 정보 사용
        Integer studentId = (Integer) session.getAttribute("studentId");
        String studentName = (String) session.getAttribute("studentName");
        
        // 4. DAO를 사용해서 DB 조회
        try {
            StudentDAO studentDAO = new StudentDAO(null);
            Student student = studentDAO.selectById(studentId);
            
            // 학생 정보를 request에 담아서 JSP로 전달
            request.setAttribute("student", student);
            request.getRequestDispatcher("/mypage.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            // 에러 처리
        }
    }
}
```

---

## 4. DAO에서 현재 로그인한 학생 정보 사용하기

```java
// Servlet에서 studentId를 DAO 메서드에 전달
Integer studentId = (Integer) session.getAttribute("studentId");

EnrollmentDAO enrollmentDAO = new EnrollmentDAO(null);
List<EnrollmentDetail> myEnrollments = enrollmentDAO.getMyEnrollment(studentId);
```

---

## 5. 주의사항

### ✅ DO (해야 할 것)
```java
// 항상 null 체크
Integer studentId = (Integer) session.getAttribute("studentId");
if (studentId == null) {
    // 로그인 페이지로 리다이렉트
}

// 타입 캐스팅 확인
Integer studentId = (Integer) session.getAttribute("studentId");  // OK
String studentName = (String) session.getAttribute("studentName"); // OK
```

### ❌ DON'T (하지 말아야 할 것)
```java
// 타입 캐스팅 없이 사용 (컴파일 에러)
int id = session.getAttribute("studentId");  // ❌ 에러!

// null 체크 없이 사용 (NullPointerException 위험)
int id = (Integer) session.getAttribute("studentId");  // ❌ 위험!
id = id + 1;  // null이면 에러 발생!
```

---

## 6. 예제: 내 수강신청 목록 조회

### MyEnrollmentServlet.java
```java
package com.team12.auction.servlet;

import com.team12.auction.dao.EnrollmentDAO;
import com.team12.auction.model.dto.EnrollmentDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/enrollment/my")
public class MyEnrollmentServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. 세션에서 학번 가져오기
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        Integer studentId = (Integer) session.getAttribute("studentId");
        
        // 2. DAO를 사용해서 내 수강신청 목록 조회
        try {
            EnrollmentDAO enrollmentDAO = new EnrollmentDAO(null);
            List<EnrollmentDetail> myEnrollments = enrollmentDAO.getMyEnrollment(studentId);
            
            // 3. JSP에 데이터 전달
            request.setAttribute("enrollments", myEnrollments);
            request.getRequestDispatcher("/enrollment/myEnrollment.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "조회 중 오류가 발생했습니다.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
}
```

### myEnrollment.jsp
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.team12.auction.model.dto.EnrollmentDetail" %>
<%
    // 로그인 체크
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String studentName = (String) session.getAttribute("studentName");
    List<EnrollmentDetail> enrollments = (List<EnrollmentDetail>) request.getAttribute("enrollments");
%>
<!DOCTYPE html>
<html>
<head>
    <title>내 수강신청 목록</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/style.css">
</head>
<body>
    <h1><%= studentName %>님의 수강신청 목록</h1>
    
    <table border="1">
        <tr>
            <th>분반ID</th>
            <th>강의명</th>
            <th>교수</th>
            <th>정원</th>
        </tr>
        <%
            if (enrollments != null && !enrollments.isEmpty()) {
                for (EnrollmentDetail e : enrollments) {
        %>
        <tr>
            <td><%= e.getSectionId() %></td>
            <td><%= e.getCourseName() %></td>
            <td><%= e.getProfessor() %></td>
            <td><%= e.getCapacity() %></td>
        </tr>
        <%
                }
            } else {
        %>
        <tr>
            <td colspan="4">수강신청한 과목이 없습니다.</td>
        </tr>
        <%
            }
        %>
    </table>
    
    <a href="<%=request.getContextPath()%>/main.jsp">메인으로</a>
</body>
</html>
```

---

## 7. 빠른 참조

| 작업 | 코드 |
|------|------|
| 세션 가져오기 | `HttpSession session = request.getSession(false);` |
| 학번 가져오기 | `Integer studentId = (Integer) session.getAttribute("studentId");` |
| 이름 가져오기 | `String studentName = (String) session.getAttribute("studentName");` |
| 로그인 체크 | `if (studentId == null) { response.sendRedirect("/login.jsp"); return; }` |
| 로그아웃 | `session.invalidate();` |

---

## 8. 문제 해결

### Q: NullPointerException 발생
```java
// A: 반드시 null 체크 후 사용
Integer studentId = (Integer) session.getAttribute("studentId");
if (studentId == null) {
    // 로그인 안 됨 처리
    return;
}
// 여기서부터 studentId 사용 가능
```

### Q: 로그인했는데 자꾸 로그인 페이지로 이동
```java
// A: getSession(false) 대신 getSession() 사용 확인
HttpSession session = request.getSession();  // 세션 생성
```

### Q: int로 형변환 에러
```java
// A: Integer로 받아야 함 (Wrapper 클래스)
Integer studentId = (Integer) session.getAttribute("studentId");  // ✅
int studentId = (Integer) session.getAttribute("studentId");      // ❌
```

### Q: 세션이 자꾸 사라짐
```xml
<!-- A: 세션 타임아웃 설정 확인 (web.xml) -->
<session-config>
    <session-timeout>30</session-timeout>  <!-- 30분 -->
</session-config>
```

---

## 추가 도움말

### 세션 디버깅
```jsp
<%
    // 현재 세션에 저장된 모든 정보 출력 (디버깅용)
    java.util.Enumeration<String> attrs = session.getAttributeNames();
    while (attrs.hasMoreElements()) {
        String name = attrs.nextElement();
        out.println(name + " = " + session.getAttribute(name) + "<br>");
    }
%>
```

### 여러 페이지에서 공통으로 사용할 로그인 체크 코드
**loginCheck.jsp** (include용)
```jsp
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
```

**다른 JSP에서 사용**
```jsp
<%@ include file="/loginCheck.jsp" %>
```

---

## 참고사항
- 세션은 서버 메모리에 저장되므로 서버 재시작 시 초기화됩니다
- 기본 세션 타임아웃은 30분입니다
- 보안을 위해 중요한 정보는 세션에 최소한으로 저장하세요
- 로그아웃 시 반드시 `session.invalidate()`를 호출하세요



---
마지막 수정: 2025-12-04