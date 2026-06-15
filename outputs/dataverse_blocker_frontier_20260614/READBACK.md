{
  "total_fronteras": 12,
  "resolucion": {
    "mixta": 2,
    "humana": 5,
    "gate": 3,
    "automatica": 2
  },
  "estado": {
    "bloqueante": 9,
    "observado": 2,
    "mitigable": 1
  },
  "conclusion": "La frontera dominante es humana/gate: identidad, approvals, live writes y target exacto. La frontera automática existe, pero no reemplaza el gate cuando hay escritura, aprobación o seguridad."
}
