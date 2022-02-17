# OpenMIPS_KIMWENG_sopc
### Project簡介
本Project結合了碩士班上課的內容、書籍「CPU自制入門」、書籍「自己動手寫CPU」完成一個MIPS32架構的CPU
主要以「自己動手寫CPU」為主，「CPU自制入門」為輔，進行code的仿寫，
改良了一些我覺得比較好的寫法。

### 目標
本Project主要實現一個MIPS32的CPU，
除了實現MIPS32的所有指令外，
還要實現協同處理器，滿足對各種異常(如:溢位、中斷等)的處理，
用ModelSim確定上述指令運作皆沒問題後，
還要從OpenCore下載falsh控制器、SDRAM控制器、GPIO控制器、UART控制器等模組，
然後兜入自己寫好的CPU，實現基於MIPS32的系統單晶片SOPC，
最後為MIPS32移植μC/OS-II之作業系統，
並把自己的code燒入FPGA，進一步驗證MIPS32處理器實現的正確性。

### 工具
該Project選用的FPGA是DE2-115，
使用的硬體描述語言為Verilog。

### 技術要點
在設計CPU管線的過程中，會遇到了Data dependence相關的問題，
若第一步是寫入暫存器，第二步緊接著要讀取相同的暫存器時，
由於第一步的結果還來不及送到暫存器，導致第二步會讀取到錯誤的資料，
解決的方式為數據前推，
若第一步是寫入暫存器，第二步緊接著要讀取相同的暫存器時，
則直接把第一步要寫入的數據往前回送作為第二步要讀取的值，
如此一來就可以解決先寫後讀(RAW)可能導致的Data dependence相關的問題，

有些指令(例如:div指令)需要多週期完成，
處理這類型的指令時，需要暫停流水線，
所以為此撰寫Hazrad模塊，
當Hazrad模塊偵測到目前的指令需要多週期完成時，
會暫停流水線，直到該指令處理完成，

此外，Hazrad模塊還多設計了flush的功能，
當遇到異常(比如遇到中斷或是計算結果溢位)，
則下一步CPU要處理的指令應該要是處理常式的指令，
因此此時已送入管線的指令要無效化，
此時Hazrad模塊會發出flush信號沖刷管線，
同時給出處理常式的位址，
而協同處理器則記錄此次異常的編號以及從中斷返回的地址，
當處理完異常後，從協同處理器獲得返回的地址，
使程式回到出現異常的下一條指令處繼續執行，

在處理分支指令時，遇到了分支冒險的問題，
也就是處理器遇到分支指令時，不能在流水開始階段就判斷出分支結果，
導致運行不正確，
解決方式為把分支指令的執行階段挪到解碼階段就執行，
這樣可以把每句分支指令後面要插入的兩個nop縮減到只剩下一個，
由於插入一個nop還是會影響到運行效率，
所以在此引入延遲槽的的機制，
如果後面的某句指令移到緊接著分支指令的下一句對結果不會有影響，
則把該句指令移到分支指令的下一句(延遲槽)，
確保CPU在有分支指令的運作下不會有空窗期，

由於指令稿(.S檔)需要翻譯成2進位的檔案並燒進DE2-115的flash memory，
因此特別在Ubuntu內安裝組譯軟體，
由於把指令稿(.S檔)翻譯成2進位需要輸入多項指令(組譯、連結等)
因此撰寫了Makefile以節省步驟，
此外，由於CPU是一行一行把指令讀進來，
所以在此又特別撰寫一個C程式，把2進位檔轉化成每條指令都換行的文字檔，

在為CPU兜各個控制器模組時，由於可能發生在同一個時間點兩個模組都發出信號的狀況，
需要仲裁器來協調各個控制器存取的先後順序，
在此特別從OpenCore下載Wishbone匯流排，該模組有內建仲裁器，
為了在CPU與各個控制器模塊的中間放入Wishbone匯流排，
因此特別撰寫了Wishbone介面，
讓自己的CPU可以相容於Wishbone匯流排，

在移植μC/OS-II時，為了可以成功移植，
因此研究了μC/OS-II一些重要的運作機制，
包括對中斷的處理、排程的機制、權限等級間的調度等，
讓自己對於μC/OS-II更加熟悉，
為了讓μC/OS-II可以從flash memory載入到SDRAM內，
因此特別撰寫bootloader檔案，
讓μC/OS-II可以從flash memory順利載入SDRAM，

最後將自己的CPU燒進FPGA並且把μC/OS-II植入CPU後，
嘗試在μC/OS-II內撰寫一些程式以驗證實作結果，
例如為μC/OS-II建立一個任務，
該任務為:把一段文字藉由UART發送到螢幕上，
看結果有沒有與預期的相符，
確保CPU運作的正確性。
