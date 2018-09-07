

resource "aws_s3_bucket" "s3" {
  bucket = "${var.bucket_name}"
  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "s3" {
  bucket = "${aws_s3_bucket.s3.id}"
  policy =<<POLICY
{
  "Id": "public-s3",
  "Statement": [
    {
      "Sid": "public-s3",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.s3.id}/*",
      "Principal": {
        "AWS": [
          "*"
        ]
      }
    }
  ]
}
POLICY
}
