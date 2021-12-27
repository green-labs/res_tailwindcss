open Jest
open Expect

describe("", _ => {
  test("", _ => {
    let header = View.header
    expect(header) |> toEqual("xl:min-w-1/5")
  })
})
