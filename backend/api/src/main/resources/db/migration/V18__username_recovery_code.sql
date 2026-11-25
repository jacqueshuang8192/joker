-- 老账号在新版客户端首次验证原密码后领取恢复码。数据库只保存随机码的 SHA-256 摘要。
ALTER TABLE t_username_credential ADD recovery_hash BINARY(32) NULL;
