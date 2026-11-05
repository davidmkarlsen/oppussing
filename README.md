# Oppussing 1. etasje

Privat planlegger for oppussing: oppgaver med estimater, status, rekkefølge og bilder (nå, inspirasjon, resultat).
Siden ligger på GitHub Pages, og data og bilder lagres i Supabase. Bare e-postadressene på tilgangslisten kan logge inn.

**Adresse når alt er satt opp:** https://davidmkarlsen.github.io/oppussing/

---

## Oppsett (ca. 15 minutter)

### 1. Lag Supabase-prosjektet

1. Gå til Supabase-organisasjonen din (DavidData) og trykk **New project**.
2. Navn: `oppussing`. Velg et databasepassord (lagre det et trygt sted). Region: **North EU (Stockholm)** eller **Central EU (Frankfurt)**.
3. Vent til prosjektet er klart (et par minutter).

### 2. Kjør databaseoppsettet

1. Åpne `supabase/setup.sql` i et tekstprogram.
2. Finn linjen `('DIN-EPOST@eksempel.no')` øverst og bytt til **din private e-post**.
   Skal noen andre ha tilgang, legg til en linje til: `('DIN-EPOST@eksempel.no'), ('partner@epost.no')`.
3. I Supabase: **SQL Editor** → **New query** → lim inn hele filen → **Run**.
   Det skal stå «Success». Oppsettet lager tabellene, tilgangsreglene, bildemappen og dine 8 oppgaver.

### 3. Fortell Supabase hvor siden ligger

**Authentication** → **URL Configuration**:

- **Site URL:** `https://davidmkarlsen.github.io/oppussing/`
- **Redirect URLs:** legg til `https://davidmkarlsen.github.io/oppussing/`

Uten dette vil innloggingslenken i e-posten sende deg til feil sted.

### 4. Koble siden til prosjektet

1. I Supabase: **Project Settings** → **API** (eller **Data API** / **API Keys**).
2. Kopier **Project URL** og **anon public**-nøkkelen (kan også hete *publishable key*).
3. Lim dem inn i `config.js`:

   ```js
   window.OPPUSSING_CONFIG = {
     supabaseUrl: "https://abcdefgh.supabase.co",
     supabaseAnonKey: "eyJhbGciOi...",
   };
   ```

   Bruk **aldri** `service_role`-nøkkelen her. Anon-nøkkelen er laget for å ligge åpent, fordi tilgangsreglene i databasen er det som beskytter dataene.

### 5. Last opp til GitHub og slå på Pages

1. På github.com: **New repository** → navn `oppussing` → **Public** → **Create repository**.
2. Trykk **uploading an existing file** og dra inn alt innholdet i denne mappen: `index.html`, `config.js`, `.nojekyll`, `README.md` og mappen `supabase`. Trykk **Commit changes**.
   (`.nojekyll` er en skjult fil. Ser du den ikke, kan du hoppe over den.)
3. **Settings** → **Pages** → *Build and deployment*: **Deploy from a branch**, branch **main**, mappe **/ (root)** → **Save**.
4. Etter 1–2 minutter er siden ute på https://davidmkarlsen.github.io/oppussing/

### 6. Logg inn

Åpne adressen, skriv inn e-posten du la på tilgangslisten og trykk **Send innloggingslenke**. Trykk på lenken i e-posten. Du blir værende innlogget på den enheten, så dette trenger du sjelden gjøre.

**Tips:** På iPhone: åpne siden i Safari → Del → **Legg til på Hjem-skjerm**. Da får du den som en app.

---

## Gi noen andre tilgang

I Supabase: **Table Editor** → `allowed_users` → **Insert row** → skriv e-posten → **Save**.
Personen kan nå logge inn på samme adresse og se og endre alt. Endringer vises live hos dere begge.

Fjern tilgang ved å slette raden igjen.

## Godt å vite

- **Koden er offentlig, dataene er ikke.** Repoet må være public for at gratis GitHub Pages skal fungere. Oppgaver og bilder ligger i Supabase og kan bare leses av innloggede e-poster på tilgangslisten. Andre som logger inn med en annen e-post ser en tom side med beskjed om at de ikke har tilgang.
- **Innloggings-e-post:** Supabase sin innebygde e-posttjeneste sender bare et fåtall e-poster i timen. Får du «For mange forsøk», vent litt.
- **Pause ved lite bruk:** Gratisprosjekter i Supabase kan settes på pause etter en periode uten bruk. Da åpner du prosjektet i Supabase og trykker **Restore**. Ingen data går tapt.
- **Bilder** komprimeres automatisk til maks 2048 px før opplasting, så de tar lite plass. Gratisplanen har god plass til flere hundre bilder.

## Filer

| Fil | Hva |
|---|---|
| `index.html` | Hele appen |
| `config.js` | Adressen og den offentlige nøkkelen til Supabase-prosjektet |
| `supabase/setup.sql` | Tabeller, tilgangsregler, bildemappe og startdata |
