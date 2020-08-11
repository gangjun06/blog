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
- [생성](#생성)
- [쿼리](#쿼리)
  - [Where 사용법](#where-사용법)
  - [Order/Limit 사용법](#orderlimit-사용법)
- [수정](#수정)
  - [일괄수정](#일괄수정)
  - [Update 사용](#update-사용)
- [삭제](#삭제)
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

{{< code language="go" title="예제" isCollapsed="false">}}
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

db.AutoMigrate(...interface{})

{{< code language="go" title="AutoMigrate 예제" isCollapsed="false">}}
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
	db.AutoMigrate(models...)
  defer db.Close()
}
{{< /code >}}

# 생성
`db.Create(&foo)` 형식으로 사용할 수 있습니다
{{< code language="go" title="생성 예제" isCollapsed="false">}}
user := User{Name: "홍길동", Age: 30, CreatedAt: time.Now()}
db.Create(&user)
{{< /code >}}
# 쿼리
{{< code language="go" title="기본 사용법" isCollapsed="false">}}
// Primary Key기준으로 정렬해서 하나 가져오기
db.First(&user)
//// SELECT * FROM users ORDER BY id LIMIT 1;

// 정렬없이 하나 가져오기
db.Take(&user)
//// SELECT * FROM users LIMIT 1;

// Primary key기준으로 역순 정렬해서 하나 가져오기
db.Last(&user)
//// SELECT * FROM users ORDER BY id DESC LIMIT 1;

// 전부 가져오기
db.Find(&users)
//// SELECT * FROM users;

// primary_key가 n인 값 불러오기
db.First(&user, n)
//// SELECT * FROM users WHERE id = n;
{{< /code >}}
## Where 사용법
`db.Where(query interface{}, args ...interface{}).Find(interface{})` 형식으로 사용함
{{< code language="go" title="Where 예제" isCollapsed="true">}}
// 일치하는 첫번째 레코드 
db.Where("name = ?", "gangjun").First(&user)
//// SELECT * FROM users WHERE name = 'gangjun' ORDER BY id LIMIT 1;

// 일치하는 모든 레코드
db.Where("name = ?", "gangjun").Find(&users)
//// SELECT * FROM users WHERE name = 'gangjun';

// <>
db.Where("name <> ?", "gangjun").Find(&users)
//// SELECT * FROM users WHERE name <> 'gangjun';

// IN
db.Where("name IN (?)", []string{"gangjun", "gangjun 2"}).Find(&users)
//// SELECT * FROM users WHERE name in ('gangjun','gangjun 2');

// LIKE
db.Where("name LIKE ?", "%jin%").Find(&users)
//// SELECT * FROM users WHERE name LIKE '%jin%';

// AND
db.Where("name = ? AND age >= ?", "gangjun", "22").Find(&users)
//// SELECT * FROM users WHERE name = 'gangjun' AND age >= 22;

// Time
db.Where("updated_at > ?", lastWeek).Find(&users)
//// SELECT * FROM users WHERE updated_at > '2000-01-01 00:00:00';

// BETWEEN
db.Where("created_at BETWEEN ? AND ?", lastWeek, today).Find(&users)
//// SELECT * FROM users WHERE created_at BETWEEN '2000-01-01 00:00:00' AND '2000-01-08 00:00:00';

{{< /code >}}

{{< code language="go" title="Where struct/map 예제" isCollapsed="true">}}
// Struct
db.Where(&User{Name: "gangjun", Age: 20}).First(&user)
//// SELECT * FROM users WHERE name = "gangjun" AND age = 20 ORDER BY id LIMIT 1;

// Map
db.Where(map[string]interface{}{"name": "gangjun", "age": 20}).Find(&users)
//// SELECT * FROM users WHERE name = "gangjun" AND age = 20;

// Slice of primary keys
db.Where([]int64{20, 21, 22}).Find(&users)
//// SELECT * FROM users WHERE id IN (20, 21, 22);
{{< /code >}}

## Order/Limit 사용법

{{< code language="go" title="Order/Limit 예제" isCollapsed="false">}}
db.Order("age desc, name").Find(&users)
//// SELECT * FROM users ORDER BY age desc, name;

db.Limit(3).Find(&users)
//// SELECT * FROM users LIMIT 3;
{{< /code >}}
# 수정
## 일괄수정
{{< code language="go" title="일괄수정 예제" isCollapsed="false">}}
db.First(&user)
user.Name = "foo"
db.Save(&user)
{{< /code >}}
## Update 사용
`db.Model(interface{}).Where().Update("key", "value")` 형식으로 사용함
{{< code language="go" title="Update 예제" isCollapsed="false">}}
db.Model(&user).Where("id = ?", 10).Update("foo", "bar")

// 또는 model을 활용할 수도 있음
db.Model(&user).Where("id = ?", 10).Update(user{Foo: "bar"})
{{< /code >}}

# 삭제
`db.Delete(interface{})`로 사용함.
주로 Where와 같이 씀

{{< code language="go" title="삭제 예제" isCollapsed="false">}}
db.Where("id =  ?", 10).Delete(Users{})
{{< /code >}}