import Ecto.Query
alias HeadsUp.Repo
alias HeadsUp.Incidents.Incident


Incident
  |> where(id: 6)
  |> Repo.one()
  |> IO.inspect()

Incident
  |> where([i], i.id == 6 or i.id == 7)
  |> Repo.all()
|> IO.inspect()

(from i in Incident,
  where: i.id == 6
) |> Repo.one()
  |> IO.inspect()

from(i in Incident,
  where: i.id in [6, 7])
  |> Repo.all()
  |> IO.inspect()
