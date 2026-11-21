-- Read only. Select the game's database before running this check.
SELECT expected.table_name AS missing_table
FROM (
  SELECT 'bullfight_gameinfo' AS table_name
  UNION ALL
  SELECT 'ims_msg' AS table_name
  UNION ALL
  SELECT 'ims_tpagentgoldreport' AS table_name
  UNION ALL
  SELECT 'ims_tpcard' AS table_name
  UNION ALL
  SELECT 'ims_tpcommissions' AS table_name
  UNION ALL
  SELECT 'ims_tpcomplaint' AS table_name
  UNION ALL
  SELECT 'ims_tpgold' AS table_name
  UNION ALL
  SELECT 'ims_tpgoods' AS table_name
  UNION ALL
  SELECT 'ims_tpmoney' AS table_name
  UNION ALL
  SELECT 'ims_tporders' AS table_name
  UNION ALL
  SELECT 'ims_tpplayergoldreport' AS table_name
  UNION ALL
  SELECT 'ims_tpuser' AS table_name
  UNION ALL
  SELECT 't_account_charge' AS table_name
  UNION ALL
  SELECT 't_activity' AS table_name
  UNION ALL
  SELECT 't_activity_user' AS table_name
  UNION ALL
  SELECT 't_advert' AS table_name
  UNION ALL
  SELECT 't_agent_id' AS table_name
  UNION ALL
  SELECT 't_announcement' AS table_name
  UNION ALL
  SELECT 't_biqi_cardid' AS table_name
  UNION ALL
  SELECT 't_charge_pool' AS table_name
  UNION ALL
  SELECT 't_city' AS table_name
  UNION ALL
  SELECT 't_clu_repository_handle_history' AS table_name
  UNION ALL
  SELECT 't_clucoins_handle_history' AS table_name
  UNION ALL
  SELECT 't_config' AS table_name
  UNION ALL
  SELECT 't_fortune_record' AS table_name
  UNION ALL
  SELECT 't_free_game_activity' AS table_name
  UNION ALL
  SELECT 't_free_game_result' AS table_name
  UNION ALL
  SELECT 't_free_game_round' AS table_name
  UNION ALL
  SELECT 't_free_game_singleresult' AS table_name
  UNION ALL
  SELECT 't_free_game_total' AS table_name
  UNION ALL
  SELECT 't_free_game_totalranking' AS table_name
  UNION ALL
  SELECT 't_game' AS table_name
  UNION ALL
  SELECT 't_game_config' AS table_name
  UNION ALL
  SELECT 't_game_province' AS table_name
  UNION ALL
  SELECT 't_game_type' AS table_name
  UNION ALL
  SELECT 't_game_type_game' AS table_name
  UNION ALL
  SELECT 't_game_type_gold' AS table_name
  UNION ALL
  SELECT 't_gift_room_card' AS table_name
  UNION ALL
  SELECT 't_goods' AS table_name
  UNION ALL
  SELECT 't_group_choushui_history' AS table_name
  UNION ALL
  SELECT 't_group_game' AS table_name
  UNION ALL
  SELECT 't_group_gameconfig' AS table_name
  UNION ALL
  SELECT 't_group_notice' AS table_name
  UNION ALL
  SELECT 't_group_player' AS table_name
  UNION ALL
  SELECT 't_group_union' AS table_name
  UNION ALL
  SELECT 't_group_union_member' AS table_name
  UNION ALL
  SELECT 't_group_xiaohao_day_history' AS table_name
  UNION ALL
  SELECT 't_group_xiaohao_history' AS table_name
  UNION ALL
  SELECT 't_group_zhanji' AS table_name
  UNION ALL
  SELECT 't_level_fenchang' AS table_name
  UNION ALL
  SELECT 't_msg_playergroup' AS table_name
  UNION ALL
  SELECT 't_player' AS table_name
  UNION ALL
  SELECT 't_player_group' AS table_name
  UNION ALL
  SELECT 't_player_sharegift_record' AS table_name
  UNION ALL
  SELECT 't_player_task' AS table_name
  UNION ALL
  SELECT 't_point_change_record' AS table_name
  UNION ALL
  SELECT 't_province' AS table_name
  UNION ALL
  SELECT 't_province_agent' AS table_name
  UNION ALL
  SELECT 't_record' AS table_name
  UNION ALL
  SELECT 't_robot_send_record' AS table_name
  UNION ALL
  SELECT 't_rongcloud_server' AS table_name
  UNION ALL
  SELECT 't_sec_operator' AS table_name
  UNION ALL
  SELECT 't_sec_user' AS table_name
  UNION ALL
  SELECT 't_service_information' AS table_name
  UNION ALL
  SELECT 't_task' AS table_name
  UNION ALL
  SELECT 't_test_config' AS table_name
  UNION ALL
  SELECT 't_town' AS table_name
  UNION ALL
  SELECT 't_user' AS table_name
  UNION ALL
  SELECT 't_version' AS table_name
  UNION ALL
  SELECT 't_waiweiorder_history' AS table_name
) AS expected
LEFT JOIN information_schema.tables AS actual
  ON actual.table_schema=DATABASE() AND LOWER(actual.table_name)=expected.table_name
WHERE actual.table_name IS NULL
ORDER BY expected.table_name;
