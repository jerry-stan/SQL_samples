--listing of NHL players who played for multiple teams and scored goals for each team they played for in 2019
--returns player, team they played for, and number of goals scored for each team

USE NHL;
WITH cte_1 AS (
SELECT DISTINCT
	pi.lastName+' '+pi.firstName AS player_name
	,gpp.player_id
	,gp.team_id_for
	,ti1.teamName AS team_nm_for
	,gpp.playerType
	,COUNT(gp.play_id) OVER(PARTITION BY gpp.player_id,gp.team_id_for) AS goals_scored
	FROM game_plays_players gpp
	INNER JOIN player_info pi ON gpp.player_id = pi.player_id
	INNER JOIN game_plays gp ON gpp.play_id = gp.play_id
	LEFT JOIN team_info ti1 ON gp.team_id_for = ti1.team_id
	
	WHERE gpp.playerType = 'Scorer'
	AND gpp.play_id LIKE '2019%'
	AND ti1.teamName IS NOT NULL
			
	GROUP BY pi.lastname
	,pi.firstName
	,gpp.player_id
	,gp.team_id_for
	,ti1.teamName
	,gpp.playerType
	,gp.play_id
	),

cte_2 AS (
SELECT DISTINCT
	pi.lastName+' '+pi.firstName AS player_name
	,gpp.player_id
	,gp.team_id_for
	,ti1.teamName AS team_nm_for
	,gpp.playerType
	,COUNT(gp.team_id_for) OVER(PARTITION BY 
		gpp.player_id
		) AS team_count
	FROM game_plays_players gpp
	INNER JOIN player_info pi ON gpp.player_id = pi.player_id
	INNER JOIN game_plays gp ON gpp.play_id = gp.play_id
	LEFT JOIN team_info ti1 ON gp.team_id_for = ti1.team_id
	
	WHERE gpp.playerType = 'Scorer'
	AND gpp.play_id LIKE '2019%'
	AND ti1.teamName IS NOT NULL
			
	GROUP BY pi.lastname
	,pi.firstName
	,gpp.player_id
	,gp.team_id_for
	,ti1.teamName
	,gpp.playerType
	)

 SELECT 
 cte_1.player_name
 ,cte_1.team_nm_for
 ,cte_1.goals_scored
 --,cte_2.team_count
 FROM cte_1 INNER JOIN cte_2 ON cte_1.player_id = cte_2.player_id
 
 WHERE cte_2.team_count>1
 --AND cte_1.player_id = 8475791

 GROUP BY 
 cte_1.player_name
 ,cte_1.team_nm_for
 ,cte_1.goals_scored
 --,cte_2.team_count

 ORDER BY cte_1.player_name