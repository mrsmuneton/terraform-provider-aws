resource "aws_subnet" "subnet_1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.subnet_1_cidr}"
  availability_zone = "${var.az_1}"

  tags {
    Name = "private"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.subnet_2_cidr}"
  availability_zone = "${var.az_2}"

  tags {
    Name = "private"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.subnet_3_cidr}"
  availability_zone = "${var.az_1}"

  tags {
    Name = "db"
  }
}

resource "aws_subnet" "subnet_4" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.subnet_4_cidr}"
  availability_zone = "${var.az_2}"

  tags {
    Name = "db"
  }
}

resource "aws_subnet" "subnet_5" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${var.subnet_5_cidr}"
  availability_zone = "${var.az_2}"

  tags {
    Name = "jumpbox"
  }
}
