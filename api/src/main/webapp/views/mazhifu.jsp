<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <script src="../js/jquery-2.1.4.min.js" type="text/javascript"></script>
    <script src="../js/qrcode.js" type="text/javascript"></script>
</head>
<body>
<div>
    <div id="qrcode"></div>
    <form id="Form1" name="Form1" method="get" action="http://codepay.fateqq.com:52888/creat_order">

            <input hidden name="id"  value="${id}"  />
            <input hidden name="pay_id"  value="${pay_id}"/>
            <input hidden name="price" value="${price}" />
            <input hidden name="type"  value="${type}" />
            <input hidden name="token"  value="${token}"/>
            <input hidden name="param"  value="${param}"/>
            <input hidden name="notify_url" value="${notify_url}"/>
            <input hidden name="return_url"  value="${return_url}" />

            <input type="submit" name="sub" id="sub" value="sub"/>

    </form>
</div>
<script>
    $(document).ready(function () {
        $("#sub").click();
    })
</script>
</body>

</html>
