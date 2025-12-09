<%@ page language="java" contentType="text/html; charset=UTF-8"
        pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.team12.auction.model.dto.EnrollmentDetail"%>
<%@ include file="/auth/loginCheck.jsp"%>
<%
    request.setCharacterEncoding("UTF-8");
    String studentName = (String) session.getAttribute("studentName");

    @SuppressWarnings("unchecked")
    List<EnrollmentDetail> enrollments = (List<EnrollmentDetail>) request.getAttribute("enrollments");
    if (enrollments == null) {
        enrollments = new ArrayList<>();
    }

    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage   = (String) session.getAttribute("errorMessage");
    if (successMessage != null) session.removeAttribute("successMessage");
    if (errorMessage   != null) session.removeAttribute("errorMessage");

    String pageError = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>내 수강신청 - 수강신청 경매 시스템</title>
<link rel="stylesheet"
        href="<%=request.getContextPath()%>/assets/css/style.css">
</head>
<body class="main-page">
        <div class="container">
                <div class="header">
                        <h1>내 수강신청</h1>
                        <div class="user-info">
                                <span><strong><%= studentName %></strong>님</span> <a
                                        href="<%=request.getContextPath()%>/main.jsp" class="logout-btn">메인으로</a>
                                <a href="<%=request.getContextPath()%>/auth/logout"
                                        class="logout-btn">로그아웃</a>
                        </div>
                </div>

                <div class="content">
                        <% if (successMessage != null) { %>
                        <div class="success-message"><%= successMessage %></div>
                        <% } %>
                        <% if (errorMessage != null) { %>
                        <div class="error-message"><%= errorMessage %></div>
                        <% } %>
                        <% if (pageError != null) { %>
                        <div class="error-message"><%= pageError %></div>
                        <% } %>

                        <table class="data-table">
                                <thead>
                                        <tr>
                                                <th>강의코드</th>
                                                <th>분반</th>
                                                <th>강의명</th>
                                                <th>교수</th>
                                                <th>강의실</th>
                                                <th>정원</th>
                                                <th>신청 경로</th>
                                                <th>사용 포인트</th>
                                                <th>취소</th>
                                        </tr>
                                </thead>
                                <tbody>
                                        <% if (enrollments.isEmpty()) { %>
                                        <tr>
                                                <td colspan="9" style="text-align: center;">현재 수강중인 강의가 없습니다.</td>
                                        </tr>
                                        <% } else { %>
                                        <% for (EnrollmentDetail item : enrollments) { %>
                                        <tr>
                                                <td><%= item.getCourseId() %></td>
                                                <td><%= item.getSectionNumber() %>분반</td>
                                                <td><%= item.getCourseName() %></td>
                                                <td><%= item.getProfessor() %></td>
                                                <td><%= item.getClassroom() %></td>
                                                <td><%= item.getCapacity() %>명</td>
                                                <td><%= item.getEnrollmentSource() != null ? item.getEnrollmentSource() : "-" %></td>
                                                <td><%= item.getPointsUsed() %>점</td>
                                                <td>
                                                        <form method="post"
                                                                action="<%=request.getContextPath()%>/enrollment/cancel"
                                                                class="inline-form">
                                                                <input type="hidden" name="sectionId"
                                                                        value="<%= item.getSectionId() %>">
                                                                <input type="hidden" name="returnUrl"
                                                                        value="<%=request.getContextPath()%>/enrollment/my">
                                                                <button class="btn-secondary" type="submit">취소</button>
                                                        </form>
                                                </td>
                                        </tr>
                                        <% } %>
                                        <% } %>
                                </tbody>
                        </table>
                </div>
        </div>
</body>
</html>
