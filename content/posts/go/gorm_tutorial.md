+++
title = "gorm을 이용하여 데이터베이스 사용하기"
description = "Go언어에서 gorm라이브러리를 사용하여 mysql, sqlite 등을 사용하는 방법을 알려드립니다."
date = "2020-08-11" 
author = "Gangjun"
tags = ["go"]
+++

[gorm](https://gorm.io)이란 go의 ORM중 하나입니다. [gorm](https://gorm.io) 라이브러리를 통하여 mysql, sqlite등의 데이터베이스를 편하게 사용할 수 있습니다

> 이 글은 gorm.io의 내용을 이해하기쉽게 번역/정리하여 가져온 글입니다. 자세한 내용은 gorm.io웹사이트를 참고해주세요

# 목차
- [목차](#목차)
- [설치하기](#설치하기)
- [데이터베이스 연결하기](#데이터베이스-연결하기)
- [struct 작성하기](#struct-작성하기)
- [오토 마이그레이션](#오토-마이그레이션)
# 설치하기
```bash
go get -u github.com/jinzhu/gorm
```

# 데이터베이스 연결하기
gorm.Open(DBType, Path)로 데이터베이스를 열 수 있습니다

**open하는 코드에서 import시 gorm뿐만 아니라 드라이버도 꼭 같이 불러올것** 

{{< code language="go" title="Sqlite" isCollapsed="true" >}}
package main

import (
  "github.com/jinzhu/gorm"
  _ "github.com/jinzhu/gorm/dialects/sqlite"
)

func main() {
  db, err := gorm.Open("sqlite3", "test.db")
  defer db.Close()
}
{{< /code >}}

{{< code language="go" title="Mysql / MariaDB" isCollapsed="true" >}}
import (
  "github.com/jinzhu/gorm"
  _ "github.com/jinzhu/gorm/dialects/mysql"
)

func main() {
  // 예시: admin:1234@localhost/test_table?charset=utf8&parseTime=True&loc=Local
  db, err := gorm.Open("mysql", "<user>:<password>@tcp(<hostname>:<port>)/<dbname>?charset=utf8&parseTime=True&loc=Local")
  defer db.Close()
}
{{< /code >}}


{{< code language="go" title="PostgreSQL" isCollapsed="true" >}}
import (
  "github.com/jinzhu/gorm"
  _ "github.com/jinzhu/gorm/dialects/postgres"
)

func main() {
  db, err := gorm.Open("postgres", "host=myhost port=myport user=gorm dbname=gorm password=mypassword")
  defer db.Close()
}
{{< /code >}}


# struct 작성하기
gorm을 통하여 DB에 접근하려면 먼저 Struct을 작성해주어야 합니다.

다음 태그들을 사용할 수 있습니다

| 태그이름       | 설명                                      |
|----------------|-------------------------------------------|
| Column         | 열 이름을 원하는것으로 지정할 수 있습니다 |
| Type           | 타입을 지정합니다                         |
| Size           | 열의 크기를 지정합니다. 기본값:255        |
| PRIMARY_KEY    | 열을 primary_key로 지정합니다             |
| UNIQUE         | 열을 unique로 지정합니다                  |
| Default        | 기본값을 지정합니다                       |
| NOT_NULL       | NULL값이 들어오지 못하도록 합니다         |
| AUTO_INCREMENT | 자동증가를 시켜줍니다                     |
| INDEX          | INDEX를 생성합니다                        |

{{< code language="go" title="예제">}}
type User struct {
    ID        uint `gorm:"primary_key;unique_index;not null;"` 
    Name      string `gorm:"type:varchar(30)"`
    Email     string `gorm:"type:varchar(60);unique_index"`
    Job       string `gorm:"type:varchar(30);default:'students'"`
    JoinAt    *time.Time
}
{{< /code >}}

# 오토 마이그레이션
DB에 연결한 후, 테이블이 생성되있지 않으면 struct을 바탕으로 자동으로 생성해 줍니다

{{< code language="go" title="AutoMigrate 예제">}}
package main

import (
  "log"

  "github.com/jinzhu/gorm"
  _ "github.com/jinzhu/gorm/dialects/sqlite"
)

type foo struct {
  Bar   string
}
  

func main() {
  db, err := gorm.Open("sqlite3", "test.db")
  if err != nil{
    log.Fatal("Error While open")
  }
  var models = []interface{}{&foo{}}
	dbConnection.AutoMigrate(models...)
  defer db.Close()
}
```
{{< /code >}}
