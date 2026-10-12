# Modern Warfare 2（2009）繁體中文戰役漢化

## AI 製作告示

本漢化由 AI 助理（OpenAI Codex）依使用者指定範圍製作，包含翻譯、資源處理、字型整合、安裝與還原工具，以及文字校對和部分實機抽測。這是非官方的 AI 製作漢化，未經原遊戲開發商或發行商背書。

譯文仍可能有語意、術語或上下文錯誤。已完成的資源與抽測驗證不等於人工逐句審校或全章節通關驗證；目前尚未完成全部 18 章逐句字幕與音畫同步測試。遇到問題請附上章節、原文／畫面和重現步驟，方便後續修正。

適用：Steam App 10180，Build 25374375。預設遊戲路徑：
`D:\SteamLibrary\steamapps\common\Call of Duty Modern Warfare 2`

## 本版狀態

18 章主線劇情譯文已完成，至第十八章 **Endgame／終局**，包括結局對話及可獨立替換的簡報字幕。共 4,676 個不同翻譯鍵值，其中戰役／簡報字幕 2,365 個。文字、資源讀回、字型與安裝檔雜湊檢查通過。

本版為 v1.0 完整文字包。已抽測第一、二章實際對話及第十八章開場／簡報，並修正兩個確認視窗排版問題；安裝／還原往返通過。**尚未完成全 18 章通關、全部字幕逐句播放或音畫同步測試**。完整實測狀態見「實機測試紀錄.md」。

## 翻譯範圍

- 18 章主線對話、可獨立替換的簡報字幕、結局對話。
- 戰役任務目標、教學、互動／拾取提示、死亡／失敗訊息。
- 主選單、戰役與共用設定介面、按鍵名稱、關卡名稱及說明。
- 戰役使用的槍械、裝備與配件名稱；型號、代碼及單位保留。

不包含製作人員清單、多人遊戲内容、特種作戰任務、重製圖片／影片畫面中的英文、中文配音。共用前端的模式選擇按鈕仍翻譯。無當前戰役引用的舊字串保留原文；動態引用的覆蓋仍須實機確認。

## GitHub 差分版安裝

此儲存庫提供 v1.0 差分發行版。請從 GitHub 的 **Code → Download ZIP** 下載並完整解壓縮，保留 `deltas` 與 `payload` 資料夾。本版不附原版關卡資源、遊戲執行檔或玩家存檔；需要自己已安裝的 Steam 正版遊戲（App 10180／Build 25374375）。

1. 安裝 **Python 3.9 以上**，確認 `py -3` 或 `python` 可使用；建議預留至少 4 GB 磁碟空間及 2 GB 可用記憶體。重建已在 Python 3.12.14／zlib 1.3.2 驗證；不同 zlib 版本若產出不一致，雜湊檢查會中止。
2. 關閉遊戲，雙擊本資料夾的 **安裝.cmd**。第一次會先從原版檔案（或已有的原版備份）重建 24 個漢化資源並驗證，可能耗時數分鐘，之後才執行安裝。
3. 進入遊戲「設定 → 音效」，啟用字幕。
4. 還原時關閉遊戲，執行 **還原.cmd**；還原不需要 Python。保留遊戲內的 `Codex_MW2_zhTW_Backup` 資料夾。

自訂路徑或 Python 執行檔：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\安裝差分.ps1" -GamePath "你的遊戲完整路徑" -PythonPath "你的python.exe完整路徑"
```

重建程序只在本漢化資料夾產生 `payload`，不修改遊戲。原檔／差分／重建結果任一雜湊不符都會中止。安裝與還原工具另行檢查遊戲是否關閉、原檔版本及備份完整性。GitHub 差分版與本機完整包的漢化資源內容一致；兩種包的 `安裝.cmd` 流程不同。

## 本機完整包安裝與使用

1. 關閉遊戲。保留遊戲的 `players` 資料夾備份。
2. 完整保留本資料夾與 `payload`。雙擊「安裝.cmd」，等候成功訊息。已安裝相同版本時可再次執行。
3. 啟動 Steam 的單人遊戲，進入「設定 → 音效」，將「字幕」設為「啟用」。
4. 原有按鍵配置繼續適用；提示中的按鍵依你的綁定顯示。圖片、影片本體的英文保留。

若改裝其他版本，先用**目前已安裝版本**的「還原.cmd」還原，再安裝新版本。不要先覆蓋舊版 manifest。若提示原檔版本／雜湊不符，安裝會停止。

其他路徑可使用 PowerShell：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\管理漢化.ps1" -Mode Install -GamePath "你的遊戲完整路徑"
```

## 翻譯範例

| 英文 | 本包繁中 |
| --- | --- |
| General Shepherd | 謝菲爾德將軍 |
| Captain Price | 普萊斯上尉 |
| Captain MacTavish | 麥克塔維什上尉 |
| Ghost | 幽靈 |
| Makarov | 馬卡洛夫 |
| M4A1 | M4A1 卡賓槍 |
| Intervention | Intervention 狙擊步槍 |
| Riot Shield | 防暴盾 |
| Heartbeat Sensor | 心跳感測器 |
| Pick up the weapon on the table. | 拿起桌上的武器。 |
| Rescue Prisoner #627. | 營救六二七號囚犯。 |
| Kill General Shepherd. | 擊斃謝菲爾德將軍。 |

## 18 章名稱

| 章 | 英文 | 繁中 |
| --- | --- | --- |
| 1 | S.S.D.D. | 又是老樣子 |
| 2 | Team Player | 團隊精神 |
| 3 | Cliffhanger | 攀登冰峰 |
| 4 | No Russian | 別說俄語 |
| 5 | Takedown | 追捕 |
| 6 | Wolverines! | 狼獾！ |
| 7 | The Hornet's Nest | 捅了蜂窩 |
| 8 | Exodus | 撤離 |
| 9 | The Only Easy Day... Was Yesterday | 唯一輕鬆的一天……是昨天 |
| 10 | The Gulag | 古拉格 |
| 11 | Of Their Own Accord | 自願赴戰 |
| 12 | Contingency | 應變計畫 |
| 13 | Second Sun | 第二個太陽 |
| 14 | Whiskey Hotel | 威士忌旅館 |
| 15 | Loose Ends | 滅口 |
| 16 | The Enemy of My Enemy | 敵人的敵人 |
| 17 | Just Like Old Times | 重溫舊夢 |
| 18 | Endgame | 終局 |

## 還原

關閉遊戲，在本資料夾雙擊「還原.cmd」。成功後資源和語系回到原版；安裝器建立的台灣語系連結會移除，玩家存檔不會刪除。

原版備份位於遊戲目錄的 `Codex_MW2_zhTW_Backup`。**保留這個備份以及本版 manifest.json**。管理器會先核對所有原版備份與目前檔案；檔案被其他補丁或更新改動時會停止，避免錯誤覆蓋。

若 Steam 驗證檔案或遊戲更新替換了資源，應重新確認 Build 與補丁版本後才重裝。不要以刪除原始 IWD／執行檔代替還原。
