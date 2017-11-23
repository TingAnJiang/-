# 停電預測挑戰賽

1.	整合哪些資料

- 村里資訊：村里緯度、村里經度、村里海拔

- 颱風資訊：氣壓、雨量、風速 (一開始收集局屬測站(全台31個)，後改為自動雨量站及自動氣象站資訊(較詳細，有400多個)，利用歐式距離計算該村里最近的測站，並將該颱風資訊歸類)

- 村里戶數：該村里在該颱風發生當月之戶數

- 電桿資訊：計算該村里每一種電桿有幾根(電桿總類有11種，因此有11個feature，再加上電桿總數的feature)

- 地形：分級至鄉鎮市之地形

- 落雷資訊：計算每一個村里在該颱風期間發生的洛雷次數，分為Cloud to Ground(雲對地閃電)及Intra-Cloud(雲內閃電)

2.	失敗經驗

- 不分區將資料全丟

- Regression tree ->輸random forest一點點

- PCA再Multiple linear regression ->很差

- neural network -> 不太會用，預測結果整個亂掉，放棄

- Support vector machine regression ->輸random forest一點點

- XGBoost -> 可能是不太會設參數，預測出來沒有用random forest好

3.	成功模型

將資料分為六都及非六都，利用random forest，並調整參數找RMSE最小，各自建置屬於自己最好的model。過程中嘗試各種feature組合，最後決定包含村里經緯度海拔、颱風雨量風速(細的)、村里戶數、電桿資訊。
