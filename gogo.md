# Gogoro

## resors

- [Welcome To SystemVerilog Central](http://www.asic-world.com/systemverilog/index.html) : 語法相關
- [TestBench.in](http://testbench.in) : 語法教學

## fifo

- 原理:
  - 利用 Dual Port Memory 讀寫不同 ADDR 時，來確保 Write Data 穩定後，才會去 Read Data，來避免 CDC 的 metastability 現象。
- 優點:
  - 可以 連續的 傳遞 DATA
  - 雙向 hand shake 確保一定沒事，很萬用
- 缺點:
  - 使用 Memory，所以面積大
  - 雙向 hand shake 會有 delay
  - 需要額外電路 (Binary to GrayCode, 2FF) 來確保，在不同 Domain 下的 Read/Write 不會同時存取到相同的 address。
  - 需要額外訊號去監控目前 FIFO 是 empty 還是 full，來告知其他電路是否可以繼續讀寫。
- 其他
  - 雙向 hand shake 會有 delay，但有幫助 FIFO 的穩定性。例如 Write addr 寫滿 FULL 的時候，Read addr 在前 2 cycle，但實際上對於 Read 來說還沒滿，還可以繼續讀，讓穩定性增加。
  - FIFO 最少幾級才能夠連續讀寫?
    - 來回交握的時間 (6 ~ 7 級)，通常會用 2 次冪，所以是 8 級
    - 以圖例來說，雙向交握會經過 W FIFO (1FF) > 2FF > R FIFO (1FF) > 2FF ⇒ 總共 6 級 FF
    - Fig
      ![fifo](https://imgur.com/1mMm84C.jpg)
- Fig
  ![fifo](https://imgur.com/0cBEfMN.jpg)
- REF: [[IC設計] Asynchronous FIFO，使用非同步FIFO解決bus CDC(Crossing clock domain)問題](https://www.tutortecho.com/post/crossing-clock-domain-asynchronous-fifo-%E4%BD%BF%E7%94%A8%E9%9D%9E%E5%90%8C%E6%AD%A5fifo%E8%A7%A3%E6%B1%BAcdc%E5%95%8F%E9%A1%8C)
