## 1. 인증 API (Authentication)

### 1.1 관리자 로그인
- **Endpoint**: `/api/auth/login`
- **Method**: POST
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "token": "string",
      "admin_id": "string",
      "name": "string",
      "role": "string",
    },
    "message": "로그인 성공"
  }
  ```

role = 'chief_manager', 'post_manager' , 'chat_manager', 'user_manager', 'data_manger'
### 1.2 관리자 회원가입
- **Endpoint**: `/api/auth/register`
- **Method**: POST
- **Request Body**:
  ```json
  {
    "name": "string",
    "email": "string",
    "email_certification": true,
    "password": "string",
    "password_confirm": "string",
    "invite_code": "string"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "회원가입 성공"
  }
  ```

### 1.3 관리자 초대 코드 생성
- **Endpoint**: `/api/auth/invite-code/generate`
- **Method**: POST
- **Request Body**:
  ```json
  {
    "email": "string",
    "role": "string",
    "time_stamp": "timestamp" // 요청 날짜(2025-02-22)
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "code": "string",
      "expires_at": "timestamp"
    },
    "message": "초대 코드 생성 완료"
  }
  ```

### 1.4 초대 코드 검증
- **Endpoint**: `/api/auth/invite-code/validate`
- **Method**: POST
- **Request Body**:
  ```json
  {
    "code": "string"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "is_valid": true,
      "role": "string"
    },
    "message": "&role 로 인증된 유효한 코드입니다"
  }
  ```

## 2. 사용자 관리 API (User Management)

### 2.1 사용자 목록 조회
- **Endpoint**: `/api/users`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `search`: string (검색어)
  - `status`: string (상태 필터: all, active, suspended, deleted)
  - `sort_by`: string (정렬 기준: created_at, last_login)
  - `sort_order`: string (정렬 순서: asc, desc)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "users": [
        {
          "user_id": "string",
          "user_name": "string",
          "email": "string",
          "verify": ["string"],
          "created_at": "timestamp",
          "last_login_at": "timestamp",
          "report_count": "number",
          "country_code": "string",
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 2.2 사용자 상세 정보 조회
- **Endpoint**: `/api/users/{user_id}`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "user_id": "string",
      "user_name": "string",
      "email": "string",
      "phone_number": "string",
      "profile_picture": "string",
      "created_at": "timestamp",
      "last_login_at": "timestamp",
      "birthdate": "timestamp",
      "post_count": "number",
      "report_count": "number",
      "country_code": "string",
      "gender": "string",
      "interest_keywords": ["string"],
      "location": "string",
      "native_language": "string",
      "preferred_language" : "string",
      "info":{
      "bio" : "",
      "followers":[],
      "following":[],
      "posts":[]
      },
    }
  }
  ```

### 2.3 사용자 계정 상태 변경
- **Endpoint**: `/api/users/{user_id}/status`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "status": "string", // active, suspended, deleted
    "reason": "string",
    "duration_days": "number" // 정지 기간(일), status가 suspended일 경우
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "사용자 상태가 변경되었습니다"
  }
  ```

### 2.4 사용자 통계 대시보드 데이터
- **Endpoint**: `/api/users/statistics`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
  - `interval`: string (daily, weekly, monthly)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "total_users": "number",
      "new_users": "number",
      "active_users": "number",
      "user_trend": [
        {
          "date": "string",
          "count": "number",
          "new_users": "number",
          "active_users": "number"
        }
      ],
      "report_stats": {
        "total": "number",
        "pending": "number",
        "resolved": "number",
        "by_category": [
          {
            "category": "string",
            "count": "number"
          }
        ]
      }
    }
  }
  ```

### 2.5 사용자 탈퇴 사유 통계
- **Endpoint**: `/api/users/withdrawal-reasons`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "total": "number",
      "by_reason": [
        {
          "reason": "string",
          "count": "number",
          "percentage": "number"
        }
      ],
      "trend": [
        {
          "date": "string",
          "count": "number"
        }
      ]
    }
  }
  ```

## 3. 신고 관리 API (Report Management)

### 3.1 사용자 신고 목록 조회
- **Endpoint**: `/api/reports/users`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `status`: string (상태 필터: all, pending, resolved, rejected)
  - `sort_by`: string (정렬 기준: created_at, severity)
  - `sort_order`: string (정렬 순서: asc, desc)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "reports": [
        {
          "report_id": "string",
          "reported_user_id": "string",
          "reported_user_name": "string",
          "reporter_user_id": "string",
          "reason": "string",
          "description": "string",
          "status": "string",
          "created_at": "timestamp",
          "severity": "number"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 3.2 게시물 신고 목록 조회
- **Endpoint**: `/api/reports/posts`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `status`: string (상태 필터: all, pending, resolved, rejected)
  - `sort_by`: string (정렬 기준: created_at, severity)
  - `sort_order`: string (정렬 순서: asc, desc)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "reports": [
        {
          "report_id": "string",
          "post_id": "string",
          "post_title": "string",
          "reporter_user_id": "string",
          "reason": "string",
          "description": "string",
          "status": "string",
          "created_at": "timestamp",
          "severity": "number"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 3.3 채팅 신고 목록 조회
- **Endpoint**: `/api/reports/chats`
- **Method**: GET
- **Query Parameters**:
  - 상기 신고 목록 조회와 동일
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "reports": [
        {
          "report_id": "string",
          "chat_id": "string",
          "chat_room_id": "string",
          "reporter_user_id": "string",
          "reported_user_id": "string",
          "reason": "string",
          "description": "string",
          "status": "string",
          "created_at": "timestamp",
          "severity": "number"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 3.4 신고 처리
- **Endpoint**: `/api/reports/{report_id}/process`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "status": "string", // resolved, rejected
    "action_taken": "string", // warn, suspend, delete_content, ban
    "comment": "string",
    "notify_reporter": "boolean",
    "notify_reported": "boolean",
    "suspension_duration": "number" // 정지 기간(일), action_taken이 suspend일 경우
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "신고가 처리되었습니다"
  }
  ```

### 3.5 신고 상세 조회
- **Endpoint**: `/api/reports/{report_id}`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "report_id": "string",
      "type": "string", // user, post, chat
      "target_id": "string",
      "target_details": "object",
      "reporter_user_id": "string",
      "reporter_details": {
        "username": "string",
        "email": "string"
      },
      "reason": "string",
      "description": "string",
      "evidence": ["string"], // 첨부 파일/이미지 URL
      "status": "string",
      "created_at": "timestamp",
      "updated_at": "timestamp",
      "processed_by": "string",
      "processed_at": "timestamp",
      "comment": "string",
      "action_taken": "string"
    }
  }
  ```

## 4. 게시물 관리 API (Post Management)

### 4.1 게시물 목록 조회
- **Endpoint**: `/api/posts`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `status`: string (상태 필터: all, active, pending, deleted)
  - `search`: string (검색어)
  - `user_id`: string (작성자 ID)
  - `sort_by`: string (정렬 기준: created_at, likes, views)
  - `sort_order`: string (정렬 순서: asc, desc)
  - `has_reports`: boolean (신고된 게시물만 조회)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "posts": [
        {
          "post_id": "string",
          "user_id": "string",
          "status": "string",
          "created_at": "timestamp",
          "report_count": "number",
          "like_count": "number",
          "view_count": "number",
          "hash_tags": ["string"]
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 4.2 게시물 상세 조회
- **Endpoint**: `/api/posts/{post_id}`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "post_id": "string",
      "title": "string",
      "post_content": "string",
      "user_id": "string",
      "user_name": "string",
      "status": "string",
      "created_at": "timestamp",
      "updated_at": "timestamp",
      "report_count": "number",
      "like_count": "number",
      "view_count": "number",
      "comment_count": "number",
      "hash_tags": ["string"],
      "post_images": ["string"],
      "comments": [
        {
          "comment_id": "string",
          "user_id": "string",
          "user_name": "string",
          "content": "string",
          "created_at": "timestamp",
          "report_count": "number"
        }
      ],
      "reports": [
        {
          "report_id": "string",
          "reason": "string",
          "status": "string"
        }
      ]
    }
  }
  ```

### 4.3 게시물 상태 변경
- **Endpoint**: `/api/posts/{post_id}/status`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "status": "string", // active, hidden, deleted
    "reason": "string",
    "notify_user": "boolean"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "게시물 상태가 변경되었습니다"
  }
  ```

### 4.4 게시물 통계 대시보드 데이터
- **Endpoint**: `/api/posts/statistics`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
  - `interval`: string (daily, weekly, monthly)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "total_posts": "number",
      "new_posts": "number",
      "active_posts": "number",
      "post_trend": [
        {
          "date": "string",
          "count": "number",
          "like_count": "number",
          "view_count": "number"
        }
      ],
      "report_stats": {
        "total": "number",
        "pending": "number",
        "resolved": "number",
        "by_category": [
          {
            "category": "string",
            "count": "number"
          }
        ]
      }
    }
  }
  ```

### 4.5 게시물 신고 검토 대기 목록
- **Endpoint**: `/api/posts/pending-reviews`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "posts": [
        {
          "post_id": "string",
          "title": "string",
          "user_id": "string",
          "user_name": "string",
          "created_at": "timestamp",
          "flag_reason": "string",
          "severity": "number"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 4.6 게시물 검토 승인/거부
- **Endpoint**: `/api/posts/{post_id}/review`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "decision": "string", // approve, reject
    "reason": "string",
    "notify_user": "boolean"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "게시물 검토가 완료되었습니다"
  }
  ```

## 5. 해시태그 관리 API (Hashtag Management)

### 5.1 해시태그 목록 조회
- **Endpoint**: `/api/hashtags`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 50)
  - `search`: string (검색어)
  - `sort_by`: string (정렬 기준: usage_count, created_at)
  - `sort_order`: string (정렬 순서: asc, desc)
  - `type`: string (all, hot, new)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "hashtags": [
        {
          "id": "string",
          "name": "string",
          "usage_count": "number",
          "created_at": "timestamp",
          "last_used_at": "timestamp",
          "trend": "string" // hot, new, stable
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 5.2 해시태그 상세 조회
- **Endpoint**: `/api/hashtags/{hashtag_id}`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "name": "string",
      "usage_count": "number",
      "created_at": "timestamp",
      "last_used_at": "timestamp",
      "trend": "string",
      "trend_data": [
        {
          "date": "string",
          "count": "number"
        }
      ],
      "related_hashtags": [
        {
          "id": "string",
          "name": "string",
          "usage_count": "number",
          "correlation": "number"
        }
      ],
      "top_posts": [
        {
          "post_id": "string",
          "title": "string",
          "like_count": "number"
        }
      ]
    }
  }
  ```

### 5.3 해시태그 워드 클라우드 데이터
- **Endpoint**: `/api/hashtags/wordcloud`
- **Method**: GET
- **Query Parameters**:
  - `limit`: number (기본값: 100)
  - `period`: string (day, week, month, year)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "hashtags": [
        {
          "id": "string",
          "name": "string",
          "weight": "number"
        }
      ]
    }
  }
  ```

### 5.4 해시태그 상태 변경
- **Endpoint**: `/api/hashtags/{hashtag_id}/status`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "status": "string", // active, blocked, featured
    "reason": "string"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "해시태그 상태가 변경되었습니다"
  }
  ```

### 5.5 해시태그 통계 대시보드
- **Endpoint**: `/api/hashtags/statistics`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "total_hashtags": "number",
      "new_hashtags": "number",
      "trending_hashtags": [
        {
          "id": "string",
          "name": "string",
          "growth_rate": "number",
          "usage_count": "number"
        }
      ],
      "hashtag_trend": [
        {
          "date": "string",
          "count": "number",
          "new_count": "number"
        }
      ]
    }
  }
  ```

## 6. 알림 관리 API (Notification Management)

### 6.1 알림 템플릿 목록 조회
- **Endpoint**: `/api/notifications/templates`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `type`: string (all, warning, congratulation, question, answer)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "templates": [
        {
          "id": "string",
          "name": "string",
          "type": "string",
          "content": "string",
          "created_at": "timestamp",
          "updated_at": "timestamp",
          "usage_count": "number"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 6.2 알림 템플릿 생성/수정
- **Endpoint**: `/api/notifications/templates`
- **Method**: POST/PUT
- **Request Body**:
  ```json
  {
    "id": "string", // PUT 요청시 필요
    "name": "string",
    "type": "string",
    "content": "string",
    "variables": ["string"]
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "id": "string"
    },
    "message": "알림 템플릿이 저장되었습니다"
  }
  ```

### 6.3 알림 발송
- **Endpoint**: `/api/notifications/send`
- **Method**: POST
- **Request Body**:
  ```json
  {
    "recipients": ["string"], // user_id 배열
    "template_id": "string",
    "variables": {
      "key": "value"
    },
    "send_immediately": "boolean"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "notification_id": "string",
      "sent_count": "number"
    },
    "message": "알림이 발송되었습니다"
  }
  ```

### 6.4 알림 발송 내역 조회
- **Endpoint**: `/api/notifications/history`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `type`: string
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "notifications": [
        {
          "id": "string",
          "template_id": "string",
          "template_name": "string",
          "type": "string",
          "sent_at": "timestamp",
          "recipient_count": "number",
          "read_count": "number",
          "sent_by": "string"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

## 7. 채팅 관리 API (Chat Management)

### 7.1 채팅방 목록 조회
- **Endpoint**: `/api/chats/rooms`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `status`: string (all, active, archived, reported)
  - `search`: string (검색어)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "rooms": [
        {
          "room_id": "string",
          "name": "string",
          "type": "string", // direct, group
          "participants": [
            {
              "user_id": "string",
              "username": "string"
            }
          ],
          "created_at": "timestamp",
          "last_message_at": "timestamp",
          "message_count": "number",
          "report_count": "number",
          "status": "string"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 7.2 채팅방 상세 조회
- **Endpoint**: `/api/chats/rooms/{room_id}`
- **Method**: GET
- **Query Parameters**:
  - `message_limit`: number (기본값: 50)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "room_id": "string",
      "name": "string",
      "type": "string",
      "participants": [
        {
          "user_id": "string",
          "username": "string",
          "profile_image": "string",
          "joined_at": "timestamp",
          "last_active_at": "timestamp"
        }
      ],
      "created_at": "timestamp",
      "last_message_at": "timestamp",
      "message_count": "number",
      "report_count": "number",
      "status": "string",
      "messages": [
        {
          "message_id": "string",
          "user_id": "string",
          "username": "string",
          "content": "string",
          "type": "string", // text, image, file
          "created_at": "timestamp",
          "report_count": "number",
          "is_reported": "boolean"
        }
      ],
      "reports": [
        {
          "report_id": "string",
          "reporter_id": "string",
          "reporter_name": "string",
          "reason": "string",
          "status": "string",
          "created_at": "timestamp"
        }
      ]
    }
  }
  ```

### 7.3 채팅방 상태 변경
- **Endpoint**: `/api/chats/rooms/{room_id}/status`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "status": "string", // active, archived, blocked
    "reason": "string",
    "notify_participants": "boolean"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "채팅방 상태가 변경되었습니다"
  }
  ```

### 7.4 채팅 메시지 관리
- **Endpoint**: `/api/chats/messages/{message_id}/status`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "status": "string", // active, hidden, deleted
    "reason": "string",
    "notify_user": "boolean"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "메시지 상태가 변경되었습니다"
  }
  ```

## 8. 매칭 시스템 관리 API (Matching System)

### 8.1 매칭 알고리즘 설정 조회
- **Endpoint**: `/api/matching/settings`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "weight_settings": {
        "location": "number",
        "interests": "number",
        "age": "number",
        "gender": "number",
        "activity_level": "number"
      },
      "thresholds": {
        "minimum_score": "number",
        "maximum_distance": "number"
      },
      "cooldown_period": "number",
      "matches_per_day": "number",
      "last_updated": "timestamp",
      "updated_by": "string"
    }
  }
  ```

### 8.2 매칭 알고리즘 설정 업데이트
- **Endpoint**: `/api/matching/settings`
- **Method**: PUT
- **Request Body**:
  ```json
  {
    "weight_settings": {
      "location": "number",
      "interests": "number",
      "age": "number",
      "gender": "number",
      "activity_level": "number"
    },
    "thresholds": {
      "minimum_score": "number",
      "maximum_distance": "number"
    },
    "cooldown_period": "number",
    "matches_per_day": "number"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "매칭 설정이 업데이트되었습니다"
  }
  ```

### 8.3 매칭 통계 조회
- **Endpoint**: `/api/matching/statistics`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
  - `interval`: string (daily, weekly, monthly)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "total_matches": "number",
      "successful_matches": "number", // 대화로 이어진 매칭
      "success_rate": "number", // 매칭 성공률 (%)
      "average_match_score": "number",
      "match_trend": [
        {
          "date": "string",
          "count": "number",
          "success_count": "number",
          "success_rate": "number"
        }
      ],
      "match_distribution_by_factors": {
        "location": [
          {
            "range": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "interests": [
          {
            "category": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "age": [
          {
            "range": "string",
            "count": "number",
            "percentage": "number"
          }
        ]
      }
    }
  }
  ```

### 8.4 매칭 히스토리 조회
- **Endpoint**: `/api/matching/history`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `status`: string (all, successful, failed)
  - `user_id`: string (특정 사용자 매칭만 조회)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "matches": [
        {
          "match_id": "string",
          "user1_id": "string",
          "user1_name": "string",
          "user2_id": "string",
          "user2_name": "string",
          "created_at": "timestamp",
          "score": "number",
          "status": "string",
          "chat_room_id": "string",
          "message_count": "number"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 8.5 매칭 상세 조회
- **Endpoint**: `/api/matching/{match_id}`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "match_id": "string",
      "user1": {
        "user_id": "string",
        "username": "string",
        "age": "number",
        "gender": "string",
        "location": "string",
        "interests": ["string"]
      },
      "user2": {
        "user_id": "string",
        "username": "string",
        "age": "number",
        "gender": "string",
        "location": "string",
        "interests": ["string"]
      },
      "created_at": "timestamp",
      "score": "number",
      "factor_scores": {
        "location": "number",
        "interests": "number",
        "age": "number",
        "gender": "number",
        "activity_level": "number"
      },
      "status": "string",
      "chat_room_id": "string",
      "message_count": "number",
      "match_duration": "number" // 매칭 후 대화 지속 시간(분)
    }
  }
  ```

## 9. 관리자 관리 API (Admin Management)

### 9.1 관리자 목록 조회
- **Endpoint**: `/api/admins`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 20)
  - `search`: string (검색어)
  - `role`: string (역할 필터)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "admins": [
        {
          "admin_id": "string",
          "name": "string",
          "email": "string",
          "role": "string",
          "status": "string",
          "last_login_at": "timestamp",
          "created_at": "timestamp"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

### 9.2 관리자 상세 조회
- **Endpoint**: `/api/admins/{admin_id}`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "admin_id": "string",
      "name": "string",
      "email": "string",
      "role": "string",
      "permissions": ["string"],
      "status": "string",
      "last_login_at": "timestamp",
      "created_at": "timestamp",
      "updated_at": "timestamp",
      "activity_log": [
        {
          "action": "string",
          "timestamp": "timestamp",
          "details": "object"
        }
      ]
    }
  }
  ```

### 9.3 관리자 역할 및 권한 변경
- **Endpoint**: `/api/admins/{admin_id}/role`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "role": "string",
    "permissions": ["string"]
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "관리자 역할이 변경되었습니다"
  }
  ```

### 9.4 관리자 상태 변경
- **Endpoint**: `/api/admins/{admin_id}/status`
- **Method**: PATCH
- **Request Body**:
  ```json
  {
    "status": "string" // active, suspended, deleted
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "관리자 상태가 변경되었습니다"
  }
  ```

### 9.5 관리자 활동 로그 조회
- **Endpoint**: `/api/admins/activity-log`
- **Method**: GET
- **Query Parameters**:
  - `page`: number (기본값: 1)
  - `limit`: number (기본값: 50)
  - `admin_id`: string (특정 관리자 활동만 조회)
  - `action`: string (액션 타입 필터)
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "logs": [
        {
          "log_id": "string",
          "admin_id": "string",
          "admin_name": "string",
          "action": "string",
          "timestamp": "timestamp",
          "details": "object",
          "ip_address": "string"
        }
      ],
      "total_count": "number",
      "current_page": "number",
      "total_pages": "number"
    }
  }
  ```

## 10. 대시보드 API (Dashboard)

### 10.1 메인 대시보드 데이터
- **Endpoint**: `/api/dashboard/main`
- **Method**: GET
- **Query Parameters**:
  - `period`: string (day, week, month)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "user_stats": {
        "total": "number",
        "new": "number",
        "active": "number",
        "growth": "number"
      },
      "content_stats": {
        "total_posts": "number",
        "new_posts": "number",
        "pending_review": "number",
        "comment_count": "number"
      },
      "report_stats": {
        "total": "number",
        "pending": "number",
        "resolved": "number",
        "by_category": [
          {
            "category": "string",
            "count": "number"
          }
        ]
      },
      "matching_stats": {
        "total_matches": "number",
        "success_rate": "number",
        "active_chats": "number"
      },
      "recent_activity": [
        {
          "type": "string",
          "timestamp": "timestamp",
          "details": "object"
        }
      ]
    }
  }
  ```

### 10.2 사용자 성장 트렌드
- **Endpoint**: `/api/dashboard/user-trends`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
  - `interval`: string (daily, weekly, monthly)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "signup_trend": [
        {
          "date": "string",
          "count": "number"
        }
      ],
      "active_trend": [
        {
          "date": "string",
          "count": "number"
        }
      ],
      "retention_trend": [
        {
          "date": "string",
          "rate": "number"
        }
      ],
      "user_demographics": {
        "by_age": [
          {
            "range": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "by_gender": [
          {
            "gender": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "by_location": [
          {
            "location": "string",
            "count": "number",
            "percentage": "number"
          }
        ]
      }
    }
  }
  ```

### 10.3 콘텐츠 활동 트렌드
- **Endpoint**: `/api/dashboard/content-trends`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
  - `interval`: string (daily, weekly, monthly)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "post_trend": [
        {
          "date": "string",
          "count": "number"
        }
      ],
      "comment_trend": [
        {
          "date": "string",
          "count": "number"
        }
      ],
      "engagement_trend": [
        {
          "date": "string",
          "likes": "number",
          "comments": "number",
          "shares": "number"
        }
      ],
      "top_content": {
        "posts": [
          {
            "post_id": "string",
            "title": "string",
            "engagement": "number"
          }
        ],
        "hashtags": [
          {
            "id": "string",
            "name": "string",
            "usage_count": "number"
          }
        ]
      }
    }
  }
  ```

### 10.4 시스템 성능 모니터링
- **Endpoint**: `/api/dashboard/system-performance`
- **Method**: GET
- **Query Parameters**:
  - `period`: string (hour, day, week)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "api_requests": [
        {
          "timestamp": "string",
          "count": "number",
          "avg_response_time": "number"
        }
      ],
      "errors": [
        {
          "timestamp": "string",
          "count": "number",
          "top_errors": [
            {
              "type": "string",
              "count": "number",
              "percentage": "number"
            }
          ]
        }
      ],
      "resource_usage": {
        "cpu": [
          {
            "timestamp": "string",
            "usage": "number"
          }
        ],
        "memory": [
          {
            "timestamp": "string",
            "usage": "number"
          }
        ],
        "disk": [
          {
            "timestamp": "string",
            "usage": "number"
          }
        ]
      }
    }
  }
  ```

## 11. 설정 관리 API (Settings Management)

### 11.1 시스템 설정 조회
- **Endpoint**: `/api/settings/system`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "general": {
        "site_name": "string",
        "site_description": "string",
        "contact_email": "string",
        "support_email": "string"
      },
      "security": {
        "login_attempts": "number",
        "lockout_duration": "number",
        "password_policy": {
          "min_length": "number",
          "require_uppercase": "boolean",
          "require_lowercase": "boolean",
          "require_numbers": "boolean",
          "require_special_chars": "boolean"
        }
      },
      "content": {
        "max_post_length": "number",
        "max_comment_length": "number",
        "auto_review_triggers": ["string"],
        "banned_words": ["string"]
      },
      "notification": {
        "email_notifications": "boolean",
        "push_notifications": "boolean",
        "digest_frequency": "string"
      }
    }
  }
  ```

### 11.2 시스템 설정 업데이트
- **Endpoint**: `/api/settings/system`
- **Method**: PUT
- **Request Body**:
  ```json
  {
    "general": {
      "site_name": "string",
      "site_description": "string",
      "contact_email": "string",
      "support_email": "string"
    },
    "security": {
      "login_attempts": "number",
      "lockout_duration": "number",
      "password_policy": {
        "min_length": "number",
        "require_uppercase": "boolean",
        "require_lowercase": "boolean",
        "require_numbers": "boolean",
        "require_special_chars": "boolean"
      }
    },
    "content": {
      "max_post_length": "number",
      "max_comment_length": "number",
      "auto_review_triggers": ["string"],
      "banned_words": ["string"]
    },
    "notification": {
      "email_notifications": "boolean",
      "push_notifications": "boolean",
      "digest_frequency": "string"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "message": "시스템 설정이 업데이트되었습니다"
  }
  ```

### 11.3 금지어 목록 관리
- **Endpoint**: `/api/settings/banned-words`
- **Method**: GET/POST
- **Request Body (POST)**:
  ```json
  {
    "words": ["string"],
    "action": "string" // add, remove
  }
  ```
- **Response (GET)**:
  ```json
  {
    "success": true,
    "data": {
      "words": ["string"],
      "last_updated": "timestamp",
      "updated_by": "string"
    }
  }
  ```
- **Response (POST)**:
  ```json
  {
    "success": true,
    "message": "금지어 목록이 업데이트되었습니다"
  }
  ```

### 11.4 API 키 관리
- **Endpoint**: `/api/settings/api-keys`
- **Method**: GET
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "keys": [
        {
          "id": "string",
          "name": "string",
          "prefix": "string",
          "created_at": "timestamp",
          "expires_at": "timestamp",
          "last_used_at": "timestamp",
          "created_by": "string",
          "permissions": ["string"]
        }
      ]
    }
  }
  ```

### 11.5 API 키 생성
- **Endpoint**: `/api/settings/api-keys`
- **Method**: POST
- **Request Body**:
  ```json
  {
    "name": "string",
    "permissions": ["string"],
    "expires_in": "number" // 만료 기간(일)
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "id": "string",
      "key": "string", // 이 응답에서만 전체 키 제공
      "name": "string",
      "prefix": "string",
      "expires_at": "timestamp"
    },
    "message": "API 키가 생성되었습니다"
  }
  ```

### 11.6 API 키 삭제
- **Endpoint**: `/api/settings/api-keys/{key_id}`
- **Method**: DELETE
- **Response**:
  ```json
  {
    "success": true,
    "message": "API 키가 삭제되었습니다"
  }
  ```

## 12. 통계 보고서 API (Statistics & Reporting)

### 12.1 사용자 분석 보고서
- **Endpoint**: `/api/reports/user-analytics`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
  - `metrics`: string (comma-separated: signup, retention, engagement)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "overview": {
        "total_users": "number",
        "active_users": "number",
        "new_users": "number",
        "churn_rate": "number"
      },
      "retention": {
        "day1": "number",
        "day7": "number",
        "day30": "number"
      },
      "engagement": {
        "dau": "number",
        "wau": "number",
        "mau": "number",
        "dau_wau_ratio": "number",
        "sessions_per_user": "number",
        "avg_session_duration": "number"
      },
      "demographics": {
        "age_distribution": [
          {
            "range": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "gender_distribution": [
          {
            "gender": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "location_distribution": [
          {
            "location": "string",
            "count": "number",
            "percentage": "number"
          }
        ]
      }
    }
  }
  ```

### 12.2 콘텐츠 분석 보고서
- **Endpoint**: `/api/reports/content-analytics`
- **Method**: GET
- **Query Parameters**:
  - `start_date`: string (YYYY-MM-DD)
  - `end_date`: string (YYYY-MM-DD)
  - `content_type`: string (posts, comments, all)
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "overview": {
        "total_posts": "number",
        "total_comments": "number",
        "avg_likes_per_post": "number",
        "avg_comments_per_post": "number"
      },
      "engagement": {
        "most_liked_posts": [
          {
            "post_id": "string",
            "title": "string",
            "like_count": "number"
          }
        ],
        "most_commented_posts": [
          {
            "post_id": "string",
            "title": "string",
            "comment_count": "number"
          }
        ],
        "engagement_by_time": [
          {
            "hour": "number",
            "post_count": "number",
            "like_count": "number",
            "comment_count": "number"
          }
        ]
      },
      "content_trends": {
        "posts_by_day": [
          {
            "date": "string",
            "count": "number"
          }
        ],
        "comments_by_day": [
          {
            "date": "string",
            "count": "number"
          }
        ],
        "likes_by_day": [
          {
            "date": "string",
            "count": "number"
          }
        ]
      },
      "top_hashtags": [
        {
          "name": "string",
          "count": "number",
          "percentage": "number"
        }
      ]
    }
  }
  ```

## 12.3 매칭 분석 보고서

- **Endpoint**: `/api/reports/matching-analytics`
- **Method**: GET
- **Query Parameters**:
    - `start_date`: string (YYYY-MM-DD)
    - `end_date`: string (YYYY-MM-DD)
- **Response**:
    
    ```json
    {
      "success": true,
      "data": {
        "overview": {
          "total_matches": "number",
          "successful_matches": "number",
          "success_rate": "number",
          "avg_match_score": "number"
        },
        "match_quality": {
          "score_distribution": [
            {
              "range": "string",
              "count": "number",
              "percentage": "number"
            }
          ],
          "factor_influence": [
            {
              "factor": "string",
              "influence": "number"
            }
          ]
        },
        "user_experience": {
          "avg_time_to_match": "number",
          "avg_messages_per_match": "number",
          "rematch_rate": "number",
          "satisfaction_score": "number"
        },
        "trends": {
          "matches_by_day": [
            {
              "date": "string",
              "count": "number",
              "success_count": "number"
            }
          ],
          "success_rate_by_day": [
            {
              "date": "string",
              "rate": "number"
            }
          ]
        }
      }
    }
    ```
    

### 12.4 모듈레이션 활동 보고서

- **Endpoint**: `/api/reports/moderation-analytics`
- **Method**: GET
- **Query Parameters**:
    - `start_date`: string (YYYY-MM-DD)
    - `end_date`: string (YYYY-MM-DD)
    - `type`: string (all, user, post, chat)
- **Response**:
    
    ```json
    {
      "success": true,
      "data": {
        "overview": {
          "total_reports": "number",
          "resolved_reports": "number",
          "rejected_reports": "number",
          "avg_resolution_time": "number"
        },
        "reports_by_type": [
          {
            "type": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "reports_by_reason": [
          {
            "reason": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "actions_taken": [
          {
            "action": "string",
            "count": "number",
            "percentage": "number"
          }
        ],
        "admin_activity": [
          {
            "admin_id": "string",
            "admin_name": "string",
            "reports_processed": "number",
            "avg_resolution_time": "number"
          }
        ],
        "trends": {
          "reports_by_day": [
            {
              "date": "string",
              "count": "number",
              "resolved_count": "number"
            }
          ],
          "resolution_time_by_day": [
            {
              "date": "string",
              "avg_time": "number"
            }
          ]
        }
      }
    }
    ```
    

### 12.5 커스텀 보고서 생성

- **Endpoint**: `/api/reports/custom`
- **Method**: POST
- **Request Body**:
    
    ```json
    {
      "name": "string",
      "description": "string",
      "metrics": ["string"],
      "filters": {
        "start_date": "string",
        "end_date": "string",
        "other_filters": {
          "key": "value"
        }
      },
      "group_by": "string",
      "format": "string" // json, csv, pdf
    }
    ```
    
- **Response**:
    
    ```json
    {
      "success": true,
      "data": {
        "report_id": "string",
        "download_url": "string",
        "expires_at": "timestamp"
      },
      "message": "보고서가 생성되었습니다"
    }
    ```
    

### 12.6 정기 보고서 설정

- **Endpoint**: `/api/reports/scheduled`
- **Method**: GET/POST
- **Request Body (POST)**:
    
    ```json
    {
      "name": "string",
      "description": "string",
      "metrics": ["string"],
      "filters": {
        "other_filters": {
          "key": "value"
        }
      },
      "schedule": {
        "frequency": "string", // daily, weekly, monthly
        "day": "number", // 주간/월간 보고서의 경우
        "time": "string", // HH:MM
        "timezone": "string"
      },
      "recipients": ["string"], // 이메일 주소
      "format": "string" // json, csv, pdf
    }
    ```
    
- **Response (GET)**:
    
    ```json
    {
      "success": true,
      "data": {
        "reports": [
          {
            "id": "string",
            "name": "string",
            "description": "string",
            "frequency": "string",
            "next_run_at": "timestamp",
            "created_by": "string",
            "created_at": "timestamp"
          }
        ]
      }
    }
    ```
    
- **Response (POST)**:
    
    ```json
    {
      "success": true,
      "data": {
        "id": "string",
        "next_run_at": "timestamp"
      },
      "message": "정기 보고서가 설정되었습니다"
    }
    ```
    

### 12.7 보고서 히스토리 조회

- **Endpoint**: `/api/reports/history`
- **Method**: GET
- **Query Parameters**:
    - `page`: number (기본값: 1)
    - `limit`: number (기본값: 20)
    - `type`: string (all, user, content, matching, moderation, custom)
- **Response**:
    
    ```json
    {
      "success": true,
      "data": {
        "reports": [
          {
            "id": "string",
            "name": "string",
            "type": "string",
            "created_at": "timestamp",
            "created_by": "string",
            "download_url": "string",
            "expires_at": "timestamp"
          }
        ],
        "total_count": "number",
        "current_page": "number",
        "total_pages": "number"
      }
    }
    ```
    

## 13. 오류 및 응답 형식

### 13.1 성공 응답 형식

```json
{
  "success": true,
  "data": "object or array", // 응답 데이터
  "message": "string" // 선택적 메시지
}
```

### 13.2 실패 응답 형식

```json
{
  "success": false,
  "error": {
    "code": "string", // 에러 코드
    "message": "string", // 에러 메시지
    "details": "object" // 추가 상세 정보 (선택 사항)
  }
}
```

### 13.3 주요 에러 코드

- `AUTH_ERROR`: 인증 관련 오류
- `VALIDATION_ERROR`: 요청 데이터 유효성 검증 오류
- `NOT_FOUND`: 요청한 리소스를 찾을 수 없음
- `PERMISSION_DENIED`: 권한 부족
- `RATE_LIMIT_EXCEEDED`: 요청 한도 초과
- `INTERNAL_ERROR`: 서버 내부 오류
