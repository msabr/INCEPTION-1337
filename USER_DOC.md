# User Documentation

This page tells you, in easy words, how to use the website once it is
running. You do not need to know Docker to read this.

## 1. What this project gives you

When the project runs, you get one website made of 3 parts:

- A **website** you open in your browser (WordPress).
- An **admin page** where an admin can manage the site.
- A **database**, hidden behind the scenes, that stores everything
  (posts, users, settings). You never touch it directly.

Only the website is open to the outside. The database is not.

## 2. Start and stop the project

Run these commands in the project's main folder (where the `Makefile`
is).

**Start it:**

```bash
make
```

**Stop it** (keeps your data):

```bash
make clean
```

**Remove everything, data too:**

```bash
make fclean
```

**Start over, clean:**

```bash
make re
```

## 3. Open the website and the admin page

**Website:**

```
https://msabr.42.fr
```

**Admin page:**

```
https://msabr.42.fr/wp-admin
```

The first time, your browser will show a warning about the certificate.
This is normal. The site uses a self-made certificate, not one from a
public company. Click "Advanced" then "Continue" (words may not be the
same in every browser) to open the site.

## 4. Where to find passwords

All logins are in the project's `.env` file, at the root of the
project. Look for these:

| Name | What it is |
|---|---|
| `WP_ADMIN_USER` / `WP_ADMIN_PASS` | Admin login and password |
| `WP_ADMIN_EMAIL` | Admin email |
| `WP_USER_NAME` / `WP_USER_PASS` | A second, normal (not admin) login |
| `WP_USER_EMAIL` | That login's email |
| `DB_NAME` / `DB_USER` / `DB_USER_PASS` | Database name and login (used by WordPress only) |

To **change** a password: edit `.env`, then run `make re`. This
rebuilds the project so the new values are used. You can also change
your own password on the WordPress admin page, under **Users →
Profile**, without touching `.env`.

Never share the `.env` file. It has real passwords. Do not put it in
Git.

## 5. Check that everything works

**Check the containers are running:**

```bash
docker ps
```

You should see three running containers: `nginx`, `wordpress`, and
`mariadb`.

**Check the website:**

Open `https://msabr.42.fr`. You should see the real website. Not a
plain "Welcome to nginx!" page. Not the WordPress setup page.

**Check the admin page:**

Log in at `https://msabr.42.fr/wp-admin` with the admin login from
`.env`. If you can log in and see the dashboard, it all works.

**If something looks wrong**, check the logs:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

For more checks, see `DEV_DOC.md`.