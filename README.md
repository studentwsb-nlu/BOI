# Test Wydajności WordPress przy użyciu Apache JMeter

## 🖥️ Środowisko testowe

| Parametr              | Wartość                                  |
|-----------------------|-------------------------------------------|
| System operacyjny     | Kali Linux (VM)                          |
| RAM                   | 4 GB                                     |
| CPU                   | 4 vCPU                                   |
| Serwer WWW            | Apache2 (LAMP stack)                     |
| PHP                   | mod_php z Apache                         |
| MySQL                 | lokalny                                  |
| WordPress             | Zainstalowany lokalnie                   |
| Test obciążeniowy     | Apache JMeter (uruchomiony na tym samym VM) |
| Testowane zasoby      | Strona główna + przykładowe podstrony    |

---

## 🧪 Wyniki testów

| Parametr                          | 500 użytkowników | 1000 użytkowników | 2000 użytkowników |
|-----------------------------------|------------------|-------------------|-------------------|
| Zużycie pamięci RAM               | ~91%             | ~94%              | ~95%              |
| Obciążenie CPU (load average)     | ~0.8             | ~1.1              | ~1.6              |
| Użycie SWAP                       | ~99%             | ~100%             | ~100%             |
| Liczba błędów HTTP                | 0%               | ~5%               | ~20%             |
| Żądania HTTP/s                   | ~200             | ~1000             | ~1000–1200        |
| Obciążenie MySQL                 | Niskie           | Niskie            | Niskie            |

---

## 🧠 Wnioski

- Głównym ograniczeniem jest **RAM**, Apache zużywa większość pamięci przez wiele procesów.
- **Brak buforowania** powoduje, że każde żądanie jest pełnym wywołaniem PHP + MySQL.
- **CPU nie jest problemem** – większość zasobów nie jest w pełni wykorzystywana.
- Czas odpowiedzi pogarsza się przy >1000 wątkach przez timeouty (brak zasobów).
- MySQL nie jest obciążone – większość czasu zużywa przetwarzanie PHP.

---

## 🛡️ Wykrywanie ataku DDoS

### Objawy:

- Nagle rosnąca liczba połączeń
- Zwiększone zużycie pasma
- Dużo błędów `504`, `502`, `timeout` w logach
- Wysokie użycie zasobów systemowych bez realnych użytkowników

### Narzędzia:

- `iftop`, `nload`, `vnstat` – monitoring sieci
- `netstat`, `ss`, `lsof -i` – aktywne połączenia
- `top`, `htop`, `glances` – obciążenie systemu
- Cloudflare / WAF – automatyczne wykrywanie i blokowanie

---

## 🕵️ Dostęp do logów — ryzyka

Atakujący z dostępem do logów może uzyskać:

- **Adresy IP użytkowników** – identyfikacja odwiedzających
- **Logi logowania** – informacje o próbach logowania
- **Ścieżki systemowe**, błędy PHP – ułatwienie ataku (np. RCE)
- **Nagłówki HTTP**, ciasteczka (czasem) – możliwa kradzież sesji
- **Informacje o serwerze i wersjach oprogramowania** – ułatwia exploitację

---

## ⚠️ Braki w środowisku (realistyczne, ale nieprodukcyjne)

| Mechanizm           | Brakująca rola                         | Skutek braku                    |
|---------------------|----------------------------------------|---------------------------------|
| Cache (page/object) | Brak optymalizacji PHP/MySQL           | Wysokie zużycie RAM i CPU       |
| CDN                 | Brak ochrony i buforowania             | Wszystko trafia bezpośrednio do serwera |
| Load Balancer       | Brak skalowalności i HA                | Single point of failure         |
| Reverse Proxy / WAF | Brak ochrony warstwy aplikacyjnej      | Narażenie na DDoS i ataki OWASP |

---

## ✅ Rekomendacje

### Środowisko testowe:
- Przenieść JMeter na osobną maszynę
- Zoptymalizować Apache (`MaxRequestWorkers`, `KeepAlive Off`)
- Włączyć buforowanie (WP Super Cache, OPcache)
- Monitorować za pomocą `glances`, `htop`, `netstat`

### Środowisko produkcyjne:
- Wdrożyć CDN (np. Cloudflare)
- Włączyć caching i reverse proxy (nginx + php-fpm)
- Zastosować WAF (np. ModSecurity)
- Przeprowadzić testy z użyciem `ab`, `siege`, `k6`

---

## 📌 Podsumowanie

Test obciążeniowy wykazał, że:

- Środowisko obsługuje **ok. 1000–1200 req/sec** do momentu pojawienia się błędów
- System nie jest zoptymalizowany do pracy pod dużym ruchem
- W warunkach produkcyjnych wymagana jest dodatkowa warstwa ochrony, skalowalności i buforowania

---
