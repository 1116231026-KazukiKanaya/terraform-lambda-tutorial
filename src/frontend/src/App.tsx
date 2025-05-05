import styles from "./App.module.css"
import { useState } from "react"

function App() {

  const [fortune, setFortune] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);

  const getFortune = async () => {
    setLoading(true);
    try {
      const response = await fetch("https://d4gle0vyp2.execute-api.ap-northeast-3.amazonaws.com/dev/fortune");
      const data = await response.json();
      setFortune(data.fortune);
    } catch (error) {
      console.error("Error fetching fortune:", error);
      setFortune("エラーが発生しました。");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>おみくじ</h1>
      <button className={styles.button} onClick={getFortune}>
        おみくじを引く
      </button>

      {loading && <p className={styles.loading}>占い中...</p>}

      {!loading && fortune && (
        <p className={styles.fortuneResult}>{fortune}</p>
      )}
    </div>
  );
}

export default App
