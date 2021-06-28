1. Give each app it's own user
```
users.users.functional_news_app.isSystemUser = true;
```
2. Git clone repo to /deploy directory as stel user
```
cd /deploy && git clone <remote-repo>
```
3. Run the app as it's own user
```
#!/usr/bin/env bash
export PROD=true
doas -u functional_news_app java -jar {jar-file}
```

