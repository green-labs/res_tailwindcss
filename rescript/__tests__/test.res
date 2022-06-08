open Jest
open Expect

describe("", _ => {
  test("", _ => {
    let header = View.header
    expect(header) |> toEqual("py-1.5")
  })

  test("content", _ => {
    let header10 = View.header10
    expect(header10) |> toEqual("before:content-['']")
  })
})
