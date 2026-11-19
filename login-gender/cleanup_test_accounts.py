import sqlite3

c = sqlite3.connect("/home/ubuntu/pesantren-verse-server/data/pesantren.db")
c.execute("DELETE FROM sesi_login WHERE santri_id IN ('PV-0002','PV-0003')")
c.execute("DELETE FROM santri WHERE id IN ('PV-0002','PV-0003')")
c.commit()
print("santri:", c.execute("SELECT id,ig_username,jenis_kelamin FROM santri ORDER BY id").fetchall())
print("sesi:", c.execute("SELECT santri_id FROM sesi_login").fetchall())
