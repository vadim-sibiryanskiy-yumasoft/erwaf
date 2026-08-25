ErWAF
=====

ErWAF is a Web Application Firewall written in Erlang for educational purposes: learning the basics of Erlang, WAF and demonstrating the results.


Build
-----

    rebar3 compile

---

### Testing in shell
Run in a terminal

    rebar3 shell

Run in another terminal

Good requests:

    http -v GET localhost:8081/api/v1/users/123 'hello=world'
    http -v -f POST localhost:8081/post hello=World
    http -v DELETE localhost:8081/item/1
    http -v PUT localhost:8081/put name=John email=john@example.org
    http -v PUT localhost:8081/put \
        name=John \
        age:=29 \
        married:=false \
        hobbies:='["http", "pies"]' \
        favorite:='{"tool": "HTTPie"}' \
        bookmarks:=@./data.json \
        description=@./notes.txt
    http -v HEAD "localhost:8081/"

Bad requests:

    http -v GET localhost:8081/api/'SELECT * from U;--' 'username=Select * from Users;--'
    http -v GET localhost:8081/api/'select * from U;--' "username=UPDATE users SET pass = '1' where user = 't1' OR 1=1--"
    http -v GET localhost:8081/api/"username=SELECT * from table where id = 1 union select 1,2,3"
    http -v GET "localhost:8081/user/admin’ OR ‘1’=’1"
    http -v -f POST localhost:8081/post/'userid=SELECT * from Users where 1=1;--' "username=SELECT * from table where id = 1 union select 1,2,3"
    http -v DELETE localhost:8081/item/'Select * From Items where 1=1;--'
    http -v PUT localhost:8081/put name='DROP TABLE Users;' email=john@example.org
    http -v GET "localhost:8081/query=<script>alert(1)</script>"
    http -v HEAD "localhost:8081/'Select * From Items where 1=1;--'"
