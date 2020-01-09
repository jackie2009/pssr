# pssr
fast planar ssr for unity5.6<br>
该方案用来实现 平面反射，主要可用来做高性能大面积的湖面 海面水体反射<br>
1 相比平面反射 少了大量drawcall和 culling 真实端游项目（生死狙击2）中可省i7-7700 cpu 1ms开销<br>
2 相比常规ssr 效果接近  逻辑更简单 但性能更好 （少了raymatch的n次深度采样检,暂无实际对比数据）<br>
demo效果
![gif](/ReadMeFiles/pssr_demo.png)
项目效果
![gif](/ReadMeFiles/pssr_game.png)
