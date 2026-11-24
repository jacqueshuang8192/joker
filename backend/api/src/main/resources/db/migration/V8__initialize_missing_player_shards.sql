-- 历史注册记录可能仅存在总表。按与 data 相同的十个后缀补齐，保留分表现有余额。
START TRANSACTION;

INSERT INTO bullfight_gameinfo0 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo0 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 0 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo1 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo1 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 1 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo2 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo2 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 2 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo3 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo3 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 3 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo4 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo4 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 4 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo5 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo5 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 5 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo6 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo6 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 6 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo7 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo7 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 7 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo8 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo8 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 8 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

INSERT INTO bullfight_gameinfo9 (mid, sid, money, bycoins, freezemoney, exp, score, wintimes, losetimes, chip)
SELECT p.mid, p.sid, p.money, p.bycoins, p.freezemoney, p.exp, p.score, p.wintimes, p.losetimes, p.chip
FROM bullfight_gameinfo p
LEFT JOIN bullfight_gameinfo9 s ON s.mid = p.mid
WHERE MOD(p.mid, 10) = 9 AND s.mid IS NULL
ON DUPLICATE KEY UPDATE mid = VALUES(mid);

COMMIT;
