# =============================
# 환경 변수
# =============================
APP_NAME := server-base-api
VERSION  := 1.0.0
IMAGE_NAME := $(APP_NAME):$(VERSION)
IMAGE_TAR := $(APP_NAME)-$(VERSION).tar
SSH_HOST := poppang-server
SERVER_DIR := /home/poppang/test

# make만 입력하면 전체 파이프라인 실행
.DEFAULT_GOAL := all

# 전체 작업 = remote-deploy만 호출
all: remote-deploy

# =============================
# Step 1. JAR 빌드
# =============================
build-jar:
	@echo "----------------------------------------"
	@echo "📦 Step 1/5: JAR 빌드 시작"
	@echo "----------------------------------------"
	./gradlew clean bootJar
	@echo "✅ JAR 빌드 완료: build/libs"
	@echo ""


# =============================
# Step 2. Docker 이미지 빌드
# =============================
build-image: build-jar
	@echo "----------------------------------------"
	@echo "🐳 Step 2/5: Docker 이미지 빌드 시작"
	@echo "  - 이미지 이름: $(IMAGE_NAME)"
	@echo "----------------------------------------"
	docker buildx build --platform linux/amd64 -t $(IMAGE_NAME) --load .
	@echo "✅ Docker 이미지 빌드 완료"
	@echo ""


# =============================
# Step 3. Docker 이미지 tar 저장
# =============================
save-image: build-image
	@echo "----------------------------------------"
	@echo "📦 Step 3/5: Docker 이미지 저장 시작"
	@echo "  - 저장 파일: $(IMAGE_TAR)"
	@echo "----------------------------------------"
	docker save -o $(IMAGE_TAR) $(IMAGE_NAME)
	@echo "✅ Docker 이미지 저장 완료 → $(IMAGE_TAR)"
	@echo ""


# =============================
# Step 4. tar 파일 서버로 전송
# =============================
send-image: save-image
	@echo "----------------------------------------"
	@echo "🚚 Step 4/5: 서버로 이미지 전송 시작"
	@echo "  - 전송 파일: $(IMAGE_TAR)"
	@echo "----------------------------------------"
	scp $(IMAGE_TAR) $(SSH_HOST):$(SERVER_DIR)/
	@echo "✅ 서버 전송 완료"
	@echo ""


# =============================
# Step 5. 서버에서 이미지 로드 + 컨테이너 재실행
# =============================
remote-deploy: send-image
	@echo "----------------------------------------"
	@echo "🚀 Step 5/5: 서버에서 배포 진행"
	@echo "----------------------------------------"
	ssh $(SSH_HOST) "bash $(SERVER_DIR)/deploy-prod.sh $(SERVER_DIR)/$(IMAGE_TAR) $(IMAGE_NAME)"
	@echo "🎉 배포 완료!"
