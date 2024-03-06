require "spec_helper"

describe SchleuderCli do
  it "creates a list without admin-fingerprint" do
    listname = "testlist-#{rand}@localhost"
    output = run_cli("lists new #{listname} admin@localhost")
    expect(output).to eql("List #{listname} successfully created! Don't forget to hook it into your MTA.\nadmin@localhost subscribed to #{listname} without setting a fingerprint.\n")

    output = run_cli("lists list")
    expect(output).to include("#{listname}")
    output = run_cli("subscriptions list #{listname}")
    expect(output).to include("admin@localhost	N/A	admin")
  ensure
    run_cli("lists delete #{listname} --YES")
  end

  it "creates a list and imports keys from file but doesn't set fingerprint because the imported file contains multiple keys" do
    listname = "testlist-#{rand}@localhost"
    output = run_cli("lists new #{listname} admin@localhost spec/two_keys.asc")
    expect(output).to eql("List #{listname} successfully created! Don't forget to hook it into your MTA.\nImported: 0x59C71FB38AEE22E091C78259D06350440F759BD3 schleuder@example.org 2016-12-06\nImported: 0xA725BD56B0CA28BF3D05F45D3EBD901AEB9C74E4 first@example.net 2020-04-07\nspec/two_keys.asc contains more than one key, cannot determine which fingerprint to use. Please set it manually!\nadmin@localhost subscribed to #{listname} without setting a fingerprint.\n")

    output = run_cli("lists list")
    expect(output).to include("#{listname}")
    output = run_cli("subscriptions list #{listname}")
    expect(output).to eql("admin@localhost	N/A	admin\t\n\n")

    output = run_cli("keys list #{listname}")
    expect(output).to include("A725BD56B0CA28BF3D05F45D3EBD901AEB9C74E4 first@example.net\n59C71FB38AEE22E091C78259D06350440F759BD3 schleuder@example.org\n")
  ensure
    run_cli("lists delete #{listname} --YES")
  end

  it "creates a list with admin-fingerprint taken from imported key-file" do
    listname = "testlist-#{rand}@localhost"
    output = run_cli("lists new #{listname} admin@localhost spec/example_key.txt")
    expect(output).to eql("List #{listname} successfully created! Don't forget to hook it into your MTA.\nImported: 0xC4D60F8833789C7CAA44496FD3FFA6613AB10ECE schleuder2@example.org 2016-12-12\nadmin@localhost subscribed to #{listname} with fingerprint C4D60F8833789C7CAA44496FD3FFA6613AB10ECE.\n")

    output = run_cli("lists list")
    expect(output).to include("#{listname}")
    output = run_cli("subscriptions list #{listname}")
    expect(output).to include("admin@localhost	C4D60F8833789C7CAA44496FD3FFA6613AB10ECE	admin")
  ensure
    run_cli("lists delete #{listname} --YES")
  end

  it "does not create a list if key-file does not exist" do
    listname = "testlist-#{rand}@localhost"
    output = run_cli("lists new #{listname} admin@localhost doesnotexist.txt")
    expect(output).to eql("File not found: doesnotexist.txt\n")

    output = run_cli("lists list")
    expect(output).not_to include("#{listname}")
  end

end
