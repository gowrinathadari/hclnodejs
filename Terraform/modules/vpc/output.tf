output "vpc_id" {
    value = aws_vpc.hcl.id
  
}
output "pub_sub_1_id" {
    value = aws_subnet.pub_sub_1.id
  
}
output "pub_sub_2_id" {
    value = aws_subnet.pub_sub_2.id
  
}
output "pub_sub_3" { 
    value = aws_subnet.pub_sub_3.id
  
}
output "pvt_sub_1" {
    value = aws_subnet.pvt_sub_1.id
  
}
output "pvt_sub_2" {
    value = aws_subnet.pvt_sub_2.id
  
}
output "pvt_sub_3" {
    value = aws_subnet.pvt_sub_3.id
  
}
output "subnets" {
    value = [aws_subnet.pvt_sub_1.id, aws_subnet.pvt_sub_2.id, aws_subnet.pvt_sub_3.id]  # Replace with your actual subnet IDs
  
}