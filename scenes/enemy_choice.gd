extends Button


func setup(enemy: EnemyType):
	$Title.text = enemy.enemy_name
	$Description.text = enemy.description
	$Icon.texture = enemy.icon
