resource "aws_ecr_repository" "appointment" {
  name = "appointment"
}

output "appointment_ecr_repository_url" {
  value = aws_ecr_repository.appointment.repository_url
}

resource "aws_ecr_repository" "patient" {
  name = "patient"
}

output "patient_ecr_repository_url" {
  value = aws_ecr_repository.patient.repository_url
}