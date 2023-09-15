set --function secretDir $argv[1]
if not test -d "$secretDir"
  echo "A valid directory argument is required"
  return 1
end
for name in private-key.age public-key.age endpoint.age
  set --local file "$secretDir/$name"
  if test -f $file
    echo "Skipping $file, already exists"
  else
    if agenix -e $file
      echo "Successfully created an encrypted secret: $file"
    else
      echo "Failed to create encrypted secret: $file"
    end
  end
end
